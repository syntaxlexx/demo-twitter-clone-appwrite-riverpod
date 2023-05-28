import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../../theme/theme.dart';
import '../controller/explore_controller.dart';
import '../widgets/search_tile.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final searchCtr = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    searchCtr.dispose();

    setState(() {
      isShowUsers = false;
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTextFieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Pallete.searchBarColor,
        ));

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: TextField(
            controller: searchCtr,
            onSubmitted: (value) {
              setState(() {
                isShowUsers = true;
              });
            },
            decoration: InputDecoration(
              fillColor: Pallete.searchBarColor,
              filled: true,
              enabledBorder: appBarTextFieldBorder,
              focusedBorder: appBarTextFieldBorder,
              hintText: 'Search Twitter',
              contentPadding: const EdgeInsets.all(10).copyWith(
                left: 20,
              ),
            ),
          ),
        ),
      ),
      body: !isShowUsers
          ? const SizedBox(
              height: 20,
            )
          : ref.watch(searchUserProvider(searchCtr.text)).when(
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return SearchTile(user: user);
                    },
                  );
                },
                error: (er, st) => ErrorText(
                  error: er.toString(),
                ),
                loading: () => const Loader(),
              ),
    );
  }
}
