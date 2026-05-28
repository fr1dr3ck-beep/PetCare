import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const checkoutPayload = await req.json()
    const PAYMONGO_SECRET = Deno.env.get('PAYMONGO_SECRET')
    
    if (!PAYMONGO_SECRET) {
      return new Response(
        JSON.stringify({ error: 'Database Environment Error: PAYMONGO_SECRET is empty.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const encodedKey = btoa(PAYMONGO_SECRET + ':')

    const response = await fetch('https://api.paymongo.com/v1/checkout_sessions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${encodedKey}`
      },
      body: JSON.stringify(checkoutPayload)
    })

    const data = await response.json()

    if (!response.ok) {
      return new Response(
        JSON.stringify({ error: 'PayMongo Gateway Error', details: data.errors }),
        { status: response.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify(data),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: 'Internal server route failure.', message: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})