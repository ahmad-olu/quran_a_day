part of 'bookmark_cubit.dart';

@immutable
sealed class BookmarkState {
  const BookmarkState();
}

final class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

final class BookmarkLoaded extends BookmarkState {
  const BookmarkLoaded({required this.bookmarks});
  final List<BookmarkModel> bookmarks;
}

final class BookmarkError extends BookmarkState {
  const BookmarkError({required this.message});
  final String message;
}
