// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum CollectionViewWithTitle {
    internal enum Button {
      internal enum ShowAll {
        /// Show all
        internal static let title = L10n.tr("Localizable", "CollectionViewWithTitle.Button.ShowAll.Title")
      }
    }
  }

  internal enum ExploreViewController {
    internal enum GenresSection {
      /// Genres
      internal static let title = L10n.tr("Localizable", "ExploreViewController.GenresSection.Title")
    }
    internal enum NavigationItem {
      /// Explore
      internal static let title = L10n.tr("Localizable", "ExploreViewController.NavigationItem.Title")
    }
    internal enum NowPlayingSection {
      /// Now Playing
      internal static let title = L10n.tr("Localizable", "ExploreViewController.NowPlayingSection.Title")
    }
    internal enum PopularSection {
      /// Popular
      internal static let title = L10n.tr("Localizable", "ExploreViewController.PopularSection.Title")
    }
    internal enum TabbarItem {
      /// Explore
      internal static let title = L10n.tr("Localizable", "ExploreViewController.TabbarItem.Title")
    }
    internal enum TopRatedSection {
      /// Top Rated
      internal static let title = L10n.tr("Localizable", "ExploreViewController.TopRatedSection.Title")
    }
    internal enum TrendingSection {
      /// Trending
      internal static let title = L10n.tr("Localizable", "ExploreViewController.TrendingSection.Title")
    }
    internal enum UpcomingSection {
      /// Upcoming
      internal static let title = L10n.tr("Localizable", "ExploreViewController.UpcomingSection.Title")
    }
  }

  internal enum ListsVC {
    internal enum Button {
      /// Back
      internal static let back = L10n.tr("Localizable", "ListsVC.Button.Back")
      internal enum AddList {
        internal enum Alert {
          /// Cancel
          internal static let cancel = L10n.tr("Localizable", "ListsVC.Button.AddList.Alert.Cancel")
          /// Enter new list's name
          internal static let message = L10n.tr("Localizable", "ListsVC.Button.AddList.Alert.message")
          /// OK
          internal static let ok = L10n.tr("Localizable", "ListsVC.Button.AddList.Alert.OK")
          /// Create new list
          internal static let title = L10n.tr("Localizable", "ListsVC.Button.AddList.Alert.title")
        }
      }
      internal enum DeleteList {
        internal enum Alert {
          /// Are you sure?
          internal static let message = L10n.tr("Localizable", "ListsVC.Button.DeleteList.Alert.message")
          /// No
          internal static let no = L10n.tr("Localizable", "ListsVC.Button.DeleteList.Alert.No")
          /// Deleting the list
          internal static let title = L10n.tr("Localizable", "ListsVC.Button.DeleteList.Alert.title")
          /// Yes
          internal static let yes = L10n.tr("Localizable", "ListsVC.Button.DeleteList.Alert.Yes")
        }
        internal enum ApprovingAlert {
          /// This list is not empty. Are you really sure?
          internal static let message = L10n.tr("Localizable", "ListsVC.Button.DeleteList.ApprovingAlert.message")
          /// Deleting non-empty list
          internal static let title = L10n.tr("Localizable", "ListsVC.Button.DeleteList.ApprovingAlert.title")
        }
      }
    }
    internal enum View {
      /// Lists
      internal static let title = L10n.tr("Localizable", "ListsVC.View.title")
      internal enum Button {
        /// Add a new list
        internal static let addList = L10n.tr("Localizable", "ListsVC.View.Button.AddList")
      }
      internal enum Error {
        internal enum Alert {
          /// Something went wrong while working with lists.
          internal static let message = L10n.tr("Localizable", "ListsVC.View.Error.Alert.message")
          /// OK! (not OK)
          internal static let ok = L10n.tr("Localizable", "ListsVC.View.Error.Alert.OK")
          /// Error
          internal static let title = L10n.tr("Localizable", "ListsVC.View.Error.Alert.title")
        }
      }
      internal enum Modal {
        internal enum AddingMovie {
          internal enum Alert {
            /// The movie is already in this list.
            internal static let message = L10n.tr("Localizable", "ListsVC.View.Modal.AddingMovie.Alert.message")
            /// OK
            internal static let ok = L10n.tr("Localizable", "ListsVC.View.Modal.AddingMovie.Alert.OK")
            /// Warning
            internal static let title = L10n.tr("Localizable", "ListsVC.View.Modal.AddingMovie.Alert.title")
          }
        }
      }
    }
  }

  internal enum MovieListVC {
    internal enum Button {
      internal enum DeleteList {
        internal enum Alert {
          /// Are you sure?
          internal static let message = L10n.tr("Localizable", "MovieListVC.Button.DeleteList.Alert.message")
          /// No
          internal static let no = L10n.tr("Localizable", "MovieListVC.Button.DeleteList.Alert.No")
          /// Deleting the list
          internal static let title = L10n.tr("Localizable", "MovieListVC.Button.DeleteList.Alert.title")
          /// Yes
          internal static let yes = L10n.tr("Localizable", "MovieListVC.Button.DeleteList.Alert.Yes")
        }
      }
    }
    internal enum NavBar {
      internal enum RightButton {
        /// Edit name
        internal static let title = L10n.tr("Localizable", "MovieListVC.NavBar.RightButton.title")
        internal enum Action {
          internal enum Alert {
            /// Cancel
            internal static let cancel = L10n.tr("Localizable", "MovieListVC.NavBar.RightButton.Action.Alert.Cancel")
            /// Enter new list's name
            internal static let message = L10n.tr("Localizable", "MovieListVC.NavBar.RightButton.Action.Alert.message")
            /// OK
            internal static let ok = L10n.tr("Localizable", "MovieListVC.NavBar.RightButton.Action.Alert.OK")
            /// Change list's name
            internal static let title = L10n.tr("Localizable", "MovieListVC.NavBar.RightButton.Action.Alert.title")
          }
        }
      }
    }
    internal enum View {
      internal enum Error {
        internal enum Alert {
          /// Something went wrong while working with movie list.
          internal static let message = L10n.tr("Localizable", "MovieListVC.View.Error.Alert.message")
          /// OK! (not OK)
          internal static let ok = L10n.tr("Localizable", "MovieListVC.View.Error.Alert.OK")
          /// Error
          internal static let title = L10n.tr("Localizable", "MovieListVC.View.Error.Alert.title")
        }
      }
    }
  }

  internal enum MovieVC {
    internal enum CollectionView {
      internal enum Actors {
        /// No actors
        internal static let warning = L10n.tr("Localizable", "MovieVC.CollectionView.Actors.warning")
      }
      internal enum Crew {
        /// No credits
        internal static let warning = L10n.tr("Localizable", "MovieVC.CollectionView.Crew.warning")
      }
      internal enum Trailers {
        /// No trailers
        internal static let warning = L10n.tr("Localizable", "MovieVC.CollectionView.Trailers.warning")
      }
    }
    internal enum View {
      internal enum Genres {
        /// No genres provided
        internal static let warning = L10n.tr("Localizable", "MovieVC.View.Genres.warning")
      }
    }
  }

  internal enum MoviesListManager {
    internal enum SystemListID {
      /// Favorites
      internal static let favorites = L10n.tr("Localizable", "MoviesListManager.SystemListID.Favorites")
      /// Watch Later
      internal static let watchLater = L10n.tr("Localizable", "MoviesListManager.SystemListID.WatchLater")
    }
  }

  internal enum PersonViewController {
    /// Biography
    internal static let biography = L10n.tr("Localizable", "PersonViewController.Biography")
    /// Born on
    internal static let bornOn = L10n.tr("Localizable", "PersonViewController.BornOn")
    /// Birthday: no information
    internal static let bornOnNOImformation = L10n.tr("Localizable", "PersonViewController.BornOnNOImformation")
    /// From
    internal static let from = L10n.tr("Localizable", "PersonViewController.From")
    /// From: no information
    internal static let fromNoInformation = L10n.tr("Localizable", "PersonViewController.FromNoInformation")
    /// Info
    internal static let info = L10n.tr("Localizable", "PersonViewController.Info")
  }

  internal enum RandomMovieViewController {
    /// Next Movie
    internal static let nextMovieButton = L10n.tr("Localizable", "RandomMovieViewController.NextMovieButton")
    /// Random Movie
    internal static let title = L10n.tr("Localizable", "RandomMovieViewController.Title")
  }

  internal enum ShowAllView {
    internal enum Title {
      /// Actors
      internal static let actors = L10n.tr("Localizable", "ShowAllView.Title.Actors")
      /// Crew
      internal static let crew = L10n.tr("Localizable", "ShowAllView.Title.Crew")
      /// Now Playing
      internal static let nowPlaying = L10n.tr("Localizable", "ShowAllView.Title.NowPlaying")
      /// Popular
      internal static let popular = L10n.tr("Localizable", "ShowAllView.Title.Popular")
      /// Top Rated
      internal static let topRated = L10n.tr("Localizable", "ShowAllView.Title.TopRated")
      /// Trending
      internal static let trending = L10n.tr("Localizable", "ShowAllView.Title.Trending")
      /// Upcoming
      internal static let upcoming = L10n.tr("Localizable", "ShowAllView.Title.Upcoming")
    }
  }

  internal enum WebPlayerVC {
    internal enum Button {
      /// Back
      internal static let back = L10n.tr("Localizable", "WebPlayerVC.Button.Back")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
