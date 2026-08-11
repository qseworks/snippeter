/// Centralized route paths so navigation is refactor-safe and deep-linkable
/// (the web address bar reflects these).
///
/// The library + settings screens live inside a single [ShellRoute] that wraps
/// them in the 3-pane shell; the snippet detail, editor and "new"
/// screens are TOP-LEVEL routes pushed over the shell, so opening a snippet
/// never replaces the shell. "Starred" is no longer a route — it's a sidebar
/// filter that drives the library query and stays on /library.
class RoutePaths {
  RoutePaths._();

  // Shell child routes.
  static const String library = '/library';
  static const String settings = '/settings';

  // Top-level (root-navigator) routes, pushed over the shell.
  static String get newSnippet => '/new';
  static String snippetDetail(String id) => '/snippet/$id';
  static String snippetEdit(String id) => '/snippet/$id/edit';
}
