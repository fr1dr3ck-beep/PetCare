import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:trial_project/pet/pet_store_controller.dart';

class TransactionCalendar extends StatelessWidget {
  const TransactionCalendar({super.key});

  // 🌟 HELPER DETECTOR: Compares calendar grid cells with your Supabase logged transaction dates
  bool _isSameDay(DateTime dayA, DateTime dayB) {
    return dayA.year == dayB.year && dayA.month == dayB.month && dayA.day == dayB.day;
  }

  // 🌟 MODAL GENERATOR: Opens a full 6-row monthly table view layout upon click
  void _openFullMonthHistoryDialog(BuildContext context, PetStoreController storeState) {
    DateTime selectedDay = DateTime.now();
    DateTime focusedDay = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Filter transactions matching the selected calendar date item
            final dayTxns = storeState.pendingTransactions.where((txn) {
              // Fallback checking to match logged dates
              return storeState.transactionDates.any((loggedDate) => _isSameDay(loggedDate, selectedDay));
            }).toList();

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: Colors.deepPurple[400], size: 22),
                  const SizedBox(width: 8),
                  const Text("Transaction History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🚀 FIXED: Renders a whole month table layout grid cleanly instead of a 1-week strip row
                    TableCalendar(
                      focusedDay: focusedDay,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      calendarFormat: CalendarFormat.month, // 📊 Enforces full monthly table format constraints
                      rowHeight: 40,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      selectedDayPredicate: (day) => _isSameDay(selectedDay, day),
                      onDaySelected: (selected, focused) {
                        setDialogState(() {
                          selectedDay = selected;
                          focusedDay = focused;
                        });
                      },
                      // 🐾 EVENT INDICATOR DOTS: Draws indicators for dates with transactions
                      eventLoader: (day) {
                        bool hasTxn = storeState.transactionDates.any((d) => _isSameDay(d, day));
                        return hasTxn ? [true] : [];
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(color: Colors.deepPurple[100], shape: BoxShape.circle),
                        selectedDecoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                        markerDecoration: const BoxDecoration(color: Color(0xFF4DB6AC), shape: BoxShape.circle), // Teal matching highlights
                      ),
                    ),
                    const Divider(height: 24),

                    // 📑 TRANSACTION DISPLAYER MODULE
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Recent Verified Statements:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                    ),
                    const SizedBox(height: 8),

                    Flexible(
                      child: dayTxns.isEmpty
                          ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text("No transaction statements recorded on this date.", style: TextStyle(fontSize: 12, color: Colors.black38, fontStyle: FontStyle.italic)),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: dayTxns.length,
                        itemBuilder: (context, index) {
                          final txn = dayTxns[index];
                          return Card(
                            elevation: 0,
                            color: const Color(0xFFF5F5F7),
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: txn.status == "Confirmed" ? const Color(0xFF7CB342).withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                                child: Icon(txn.type == "Store" ? Icons.shopping_bag_outlined : Icons.room_service_outlined, size: 16, color: Colors.deepPurple),
                              ),
                              title: Text(txn.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("ID: ${txn.id} • Status: ${txn.status}", style: const TextStyle(fontSize: 10)),
                              trailing: Text("₱${txn.totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.deepPurple)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 900; //

    double containerHeight = isDesktop ? 90 : 70; //
    final storeState = Provider.of<PetStoreController>(context); // Link state engine hooks

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0), //
      child: GestureDetector(
        onTap: () => _openFullMonthHistoryDialog(context, storeState), // 🚀 Launches the full-month calendar view dialog
        child: Container(
          height: containerHeight, //
          width: double.infinity, //
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), //
            // 🌟 FIXED: Yellow color replaced with custom landscape decoration asset image pattern
            image: const DecorationImage(
              image: AssetImage('assets/images/petslider/new.jpg'), //
              fit: BoxFit.cover, // Automatically adjusts landscape bounds safely
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1, //
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0), //
                  child: Text(
                    "Transaction\nCalendar", //
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 10, //
                      fontWeight: FontWeight.bold, //
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2, //
                child: Align(
                  alignment: Alignment.centerRight, //
                  child: Padding(
                    padding: const EdgeInsets.all(6.0), //
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), //
                        borderRadius: BorderRadius.circular(15), //
                      ),
                      padding: const EdgeInsets.all(2.0), //
                      child: FittedBox(
                        fit: BoxFit.contain, // Mathematically scales calendar to the half-height
                        child: SizedBox(
                          width: 280, //
                          child: TableCalendar(
                            focusedDay: DateTime.now(), //
                            firstDay: DateTime.utc(2020, 1, 1), //
                            lastDay: DateTime.utc(2030, 12, 31), //
                            rowHeight: 30, //
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false, //
                              titleCentered: true, //
                            ),
                            // 🐾 Preview Indicator dots matching home-page layout dashboard
                            eventLoader: (day) {
                              bool hasTxn = storeState.transactionDates.any((d) => _isSameDay(d, day));
                              return hasTxn ? [true] : [];
                            },
                            calendarStyle: const CalendarStyle(
                              markerDecoration: BoxDecoration(color: Color(0xFF4DB6AC), shape: BoxShape.circle), //
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}