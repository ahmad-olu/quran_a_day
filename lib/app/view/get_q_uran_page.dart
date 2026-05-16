import 'package:al_quran/al_quran.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lamsz_quran_api/lamsz_quran_api.dart';
import 'package:quran_a_day/app/theme.dart';
import 'package:quran_a_day/state/random_page_cubit/random_page_cubit.dart';

class GetQUranPage extends StatelessWidget {
  const GetQUranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => RandomPageCubit()..getRandomPage(),
      child: const GetRandomQuranView(),
    );
  }
}

class GetRandomQuranView extends StatelessWidget {
  const GetRandomQuranView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomPageCubit, RandomPageState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton.outlined(
                onPressed: () {
                  context.read<RandomPageCubit>().getRandomPage();
                },
                icon: const Icon(
                  Icons.refresh_outlined,
                ),
              ),
            ],
          ),
          body: switch (state) {
            RandomPageInitial() => const Center(
                child: Text('Nothing here yet!'),
              ),
            RandomPageLoaded(
              ayahs: final List<(List<Aya>, SurahName, SurahName)> ayahs
            ) =>
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: ayahs.map((ayahList) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Column(
                                children: [
                                  const Divider(
                                    endIndent: 200,
                                    indent: 200,
                                  ),
                                  Text(
                                    '[${ayahList.$3}]  ${ayahList.$2}', // First Ayah
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20,
                                      // color: Colors.black,
                                    ),
                                  ),
                                  const Divider(
                                    endIndent: 200,
                                    indent: 200,
                                  ),
                                  ColoredBox(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.5),
                                    child: const Text(
                                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', // First Ayah
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: RichText(
                                      textAlign: TextAlign.justify,
                                      text: TextSpan(
                                        children: ayahList.$1
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final ayah = entry.value;
                                          return TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${ayah.arabic} ', // Ayah text
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 28,
                                                  color: context.textColor,
                                                  height: 2.5,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    ' [${ayah.id!.ar}] ', // Ayah number
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: context.textColor,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                  height: 2.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                        //  style: DefaultTextStyle.of(context).style,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
          },
        );
      },
    );
  }
}
