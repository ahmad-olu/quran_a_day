import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:gap/gap.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:quran_a_day/app/theme.dart';
import 'package:quran_a_day/app/view/get_q_uran_page.dart';
import 'package:quran_a_day/l10n/arb/app_localizations.dart';

import 'package:responsive_builder/responsive_builder.dart';

class App extends HookWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlexThemeData.light(scheme: FlexScheme.mandyRed),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
      //        themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

Stream<DateTime> getCurrentTimeStream() {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;
    final todayDate = HijriCalendar.now();
    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            final isDesktop =
                sizingInformation.deviceScreenType == DeviceScreenType.desktop;

            return SafeArea(
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    color: theme.scaffoldBackgroundColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      width: !isDesktop ? width : width / 2,
                      height: height,
                      // color: Theme.of(context).colorScheme.primary,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Gap(82),
                          Center(
                            child: Text(
                              'Quran a day',
                              style: theme.textTheme.displayMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                          ),
                          const Gap(60),
                          // IslamicHijriCalendar(),
                          StreamBuilder<DateTime>(
                            stream: getCurrentTimeStream(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const Text('Loading...');
                              final data = snapshot.data!;
                              return SizedBox(
                                height: 140,
                                width: 110,
                                child: Stack(
                                  children: [
                                    Align(
                                      child: Container(
                                        height: 140,
                                        width: 110,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            width: 0.8,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      child: Container(
                                        height: 120,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${data.hour}',
                                                    style: theme.textTheme
                                                        .displayMedium!
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${data.minute}',
                                                    style: theme.textTheme
                                                        .displayMedium!
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                                right: 2,
                                              ),
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: SizedBox(
                                                  width: 19,
                                                  child: Text(
                                                    '${data.second}',
                                                    style: theme
                                                        .textTheme.bodySmall!
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Gap(7),
                          Text(
                            '${todayDate.hYear}. ${todayDate.hDay}. ${todayDate.longMonthName} [${todayDate.hMonth}]',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const Gap(100),

                          AnimatedContainer(
                            duration: const Duration(seconds: 10),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.secondary
                                      .withValues(alpha: 0.6),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<GetQUranPage>(
                                    builder: (context) {
                                      return const GetQUranPage();
                                    },
                                  ),
                                );
                              },
                              icon: Tooltip(
                                message: 'Show Random page to Read',
                                child: Icon(
                                  FlutterIslamicIcons.solidQuran,
                                  color: theme.colorScheme.secondary,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),

                          const Gap(10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
