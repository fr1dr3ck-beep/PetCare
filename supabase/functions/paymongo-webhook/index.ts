import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  try {
    // 1. Initialize Supabase Admin Client using system service keys to bypass RLS walls
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const payload = await req.json()
    
    // 2. Parse out the secure checkout data resource block sent over by PayMongo
    const resource = payload.data?.attributes?.resource
    const eventType = payload.data?.attributes?.type // e.g., 'checkout_session.paid'

    if (eventType === 'checkout_session.payment.paid' && resource) {
      const transactionId = resource.attributes?.metadata?.transaction_id
      const paymentMethod = resource.attributes?.payment_method_used ?? 'online'
      const paymentId = resource.id

      if (transactionId) {
        // 3. Fetch the original pending transaction logged from the client application
        const { data: transaction } = await supabaseClient
          .from('pending_transactions')
          .select('*')
          .eq('id', transactionId)
          .maybeSingle()

        if (transaction && transaction.status !== 'Confirmed') {
          // 4. AUTOMATIC UPDATE: Flip transaction status flag instantly
          await supabaseClient
            .from('pending_transactions')
            .update({
              status: 'Confirmed',
              proof_of_payment: `Paid via PayMongo [${paymentMethod.toUpperCase()}] | Ref: ${paymentId}`
            })
            .eq('id', transactionId)

          // 5. AUTOMATIC SYSTEM INVENTORY DEDUCTION / SERVICE RESERVATION PIPELINE
          if (transaction.type === 'Store') {
            const storeItems = transaction.store_items_json || []
            for (const item of storeItems) {
              const { data: currentStock } = await supabaseClient
                .from('pet_stocks')
                .select('stock_level')
                .eq('pet_id', item.id)
                .maybeSingle()

              const activeQty = currentStock ? currentStock.stock_level : 25
              await supabaseClient
                .from('pet_stocks')
                .upsert({ pet_id: item.id, stock_level: activeQty - item.quantity })
            }
          } else if (transaction.type === 'Services') {
            const serviceItems = transaction.service_items_json || []
            for (const service of serviceItems) {
              await supabaseClient
                .from('registered_pets')
                .insert({
                  id: service.id,
                  service_title: service.serviceTitle,
                  total_price: service.totalPrice,
                  logistics_mode: service.logisticsMode,
                  pet_type: service.petType,
                  pet_name: service.petName,
                  pet_color: service.petColor,
                  owner_address: transaction.user_address,
                  status: `Active: ${service.serviceTitle}`,
                  user_id: transaction.user_id
                })
            }
          }

          // 6. DISPATCH AUTOMATIC SUCCESS ALERTS
          await supabaseClient
            .from('user_notifications')
            .insert({
              user_id: transaction.user_id,
              title: "Payment Confirmed! 🎉",
              message: `Your payment for order ${transactionId} was processed automatically via PayMongo.`,
              is_read: false
            })
        }
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})