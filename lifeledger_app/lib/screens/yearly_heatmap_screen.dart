import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class YearlyHeatmapScreen extends StatefulWidget {

  const YearlyHeatmapScreen({super.key});

  @override
  State<YearlyHeatmapScreen> createState() =>
      _YearlyHeatmapScreenState();
}

class _YearlyHeatmapScreenState
    extends State<YearlyHeatmapScreen> {

  DateTime today = DateTime.now();

  final Map<DateTime, String> events = {

    DateTime(2026, 1, 14): "🎉 Pongal",

    DateTime(2026, 11, 12): "🪔 Diwali",

    DateTime(2026, 12, 25): "🎄 Christmas",

    DateTime(2026, 8, 15): "🇮🇳 Independence Day",
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0a0f1e),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        title: const Text(
          "Life Activity Calendar",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              decoration: BoxDecoration(

                color:
                    Colors.white.withOpacity(0.05),

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: TableCalendar(

                focusedDay: today,

                firstDay:
                    DateTime(2024),

                lastDay:
                    DateTime(2030),

                calendarStyle:
                    CalendarStyle(

                  todayDecoration:
                      BoxDecoration(

                    color:
                        Colors.deepPurple,

                    shape:
                        BoxShape.circle,
                  ),

                  defaultTextStyle:
                      const TextStyle(

                    color:
                        Colors.white,
                  ),

                  weekendTextStyle:
                      const TextStyle(

                    color:
                        Colors.orange,
                  ),

                  markerDecoration:
                      const BoxDecoration(

                    color:
                        Colors.green,

                    shape:
                        BoxShape.circle,
                  ),
                ),

                headerStyle:
                    const HeaderStyle(

                  titleTextStyle:
                      TextStyle(

                    color:
                        Colors.white,

                    fontSize: 18,

                    fontWeight:
                        FontWeight.bold,
                  ),

                  formatButtonVisible:
                      false,

                  leftChevronIcon:
                      Icon(

                    Icons.chevron_left,

                    color:
                        Colors.white,
                  ),

                  rightChevronIcon:
                      Icon(

                    Icons.chevron_right,

                    color:
                        Colors.white,
                  ),
                ),

                calendarBuilders:
                    CalendarBuilders(

                  markerBuilder:
                      (context, date, eventsList) {

                    if (events.keys.any(

                      (d) =>

                          d.year ==
                              date.year &&

                          d.month ==
                              date.month &&

                          d.day ==
                              date.day,
                    )) {

                      return Positioned(

                        bottom: 4,

                        child: Container(

                          width: 8,

                          height: 8,

                          decoration:
                              BoxDecoration(

                            color:
                                Colors.amber,

                            shape:
                                BoxShape.circle,
                          ),
                        ),
                      );
                    }

                    return null;
                  },
                ),

                selectedDayPredicate:
                    (day) {

                  return isSameDay(
                    today,
                    day,
                  );
                },

                onDaySelected:
                    (selectedDay, focusedDay) {

                  setState(() {

                    today = selectedDay;
                  });

                  final event =
                      events.entries.firstWhere(

                    (e) =>

                        e.key.year ==
                            selectedDay.year &&

                        e.key.month ==
                            selectedDay.month &&

                        e.key.day ==
                            selectedDay.day,

                    orElse: () =>

                        MapEntry(
                          DateTime.now(),
                          "",
                        ),
                  );

                  if (event.value.isNotEmpty) {

                    showDialog(

                      context: context,

                      builder: (_) {

                        return AlertDialog(

                          backgroundColor:
                              Color(0xFF101828),

                          title: Text(

                            "Festival",

                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),

                          content: Text(

                            event.value,

                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(

                gradient: LinearGradient(

                  colors: [

                    Color(0xFF6c8fff),

                    Color(0xFFa78bfa),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: const [

                  Text(

                    "Today's Activity",

                    style: TextStyle(

                      color: Colors.white70,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(

                    "🔥 Productivity Strong",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(

                    "Habits, mood and tasks are improving consistently.",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}