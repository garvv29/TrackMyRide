import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Track My Bus'**
  String get appTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get gujarati;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get telugu;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get kannada;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം'**
  String get malayalam;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bengali;

  /// No description provided for @punjabi.
  ///
  /// In en, this message translates to:
  /// **'ਪੰਜਾਬੀ'**
  String get punjabi;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Theme'**
  String get selectTheme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick the theme that suits your style'**
  String get themeDescription;

  /// No description provided for @fromBusStand.
  ///
  /// In en, this message translates to:
  /// **'From Bus Stand'**
  String get fromBusStand;

  /// No description provided for @toBusStand.
  ///
  /// In en, this message translates to:
  /// **'To Bus Stand'**
  String get toBusStand;

  /// No description provided for @findBus.
  ///
  /// In en, this message translates to:
  /// **'Find Bus'**
  String get findBus;

  /// No description provided for @searchByBusNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by Bus Number'**
  String get searchByBusNumber;

  /// No description provided for @enterBusNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter bus number...'**
  String get enterBusNumber;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @complaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Saved Routes'**
  String get savedRoutes;

  /// No description provided for @savedBuses.
  ///
  /// In en, this message translates to:
  /// **'Saved Buses'**
  String get savedBuses;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @locationServices.
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// No description provided for @busRoute.
  ///
  /// In en, this message translates to:
  /// **'Bus Route'**
  String get busRoute;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get stops;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @busNumber.
  ///
  /// In en, this message translates to:
  /// **'Bus Number'**
  String get busNumber;

  /// No description provided for @departure.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// No description provided for @arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// No description provided for @trackMyRide.
  ///
  /// In en, this message translates to:
  /// **'Track My Ride'**
  String get trackMyRide;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// No description provided for @chooseYourStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Style'**
  String get chooseYourStyle;

  /// No description provided for @selectAppearance.
  ///
  /// In en, this message translates to:
  /// **'Select the appearance that suits you best'**
  String get selectAppearance;

  /// No description provided for @cleanBrightInterface.
  ///
  /// In en, this message translates to:
  /// **'Clean and bright interface'**
  String get cleanBrightInterface;

  /// No description provided for @easyOnEyes.
  ///
  /// In en, this message translates to:
  /// **'Easy on your eyes'**
  String get easyOnEyes;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @searchBuses.
  ///
  /// In en, this message translates to:
  /// **'Search Buses'**
  String get searchBuses;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @trackMyBus.
  ///
  /// In en, this message translates to:
  /// **'Track My Bus'**
  String get trackMyBus;

  /// No description provided for @limitedConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Limited connectivity - Some features may not work'**
  String get limitedConnectivity;

  /// No description provided for @findPerfectRoute.
  ///
  /// In en, this message translates to:
  /// **'Find the perfect route for your journey'**
  String get findPerfectRoute;

  /// No description provided for @planYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Journey'**
  String get planYourJourney;

  /// No description provided for @chooseDepartureLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose departure location'**
  String get chooseDepartureLocation;

  /// No description provided for @chooseDestinationLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose destination location'**
  String get chooseDestinationLocation;

  /// No description provided for @swapLocations.
  ///
  /// In en, this message translates to:
  /// **'Swap locations'**
  String get swapLocations;

  /// No description provided for @searchRoutes.
  ///
  /// In en, this message translates to:
  /// **'Search Routes'**
  String get searchRoutes;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentRoutesSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Routes'**
  String get recentRoutesSearches;

  /// No description provided for @nearbyStops.
  ///
  /// In en, this message translates to:
  /// **'Nearby Stops'**
  String get nearbyStops;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @pleaseEnterBothLocations.
  ///
  /// In en, this message translates to:
  /// **'Please enter both departure and destination'**
  String get pleaseEnterBothLocations;

  /// No description provided for @failedToSearchRoutes.
  ///
  /// In en, this message translates to:
  /// **'Failed to search routes'**
  String get failedToSearchRoutes;

  /// No description provided for @searchByRoute.
  ///
  /// In en, this message translates to:
  /// **'Search by Route'**
  String get searchByRoute;

  /// No description provided for @searchByNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by Number'**
  String get searchByNumber;

  /// No description provided for @enterBusStopOrArea.
  ///
  /// In en, this message translates to:
  /// **'Enter bus stop or area name'**
  String get enterBusStopOrArea;

  /// No description provided for @enterBusNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter bus number'**
  String get enterBusNumberHint;

  /// No description provided for @routeSearches.
  ///
  /// In en, this message translates to:
  /// **'Route Searches'**
  String get routeSearches;

  /// No description provided for @numberSearches.
  ///
  /// In en, this message translates to:
  /// **'Number Searches'**
  String get numberSearches;

  /// No description provided for @recentRouteSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Route Searches'**
  String get recentRouteSearches;

  /// No description provided for @recentBusSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Bus Searches'**
  String get recentBusSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get noRecentSearches;

  /// No description provided for @busDetails.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get busDetails;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @majorStops.
  ///
  /// In en, this message translates to:
  /// **'Major Stops'**
  String get majorStops;

  /// No description provided for @viewAllStops.
  ///
  /// In en, this message translates to:
  /// **'View All Stops'**
  String get viewAllStops;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @alertsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with bus alerts and notifications'**
  String get alertsNotifications;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @noAlertsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No alerts available'**
  String get noAlertsAvailable;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @stayUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with bus alerts and notifications'**
  String get stayUpdated;

  /// No description provided for @noSavedRoutes.
  ///
  /// In en, this message translates to:
  /// **'No saved routes yet'**
  String get noSavedRoutes;

  /// No description provided for @noSavedBuses.
  ///
  /// In en, this message translates to:
  /// **'No saved buses yet'**
  String get noSavedBuses;

  /// No description provided for @saveRoutesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your saved routes will appear here'**
  String get saveRoutesMessage;

  /// No description provided for @saveBusesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your saved buses will appear here'**
  String get saveBusesMessage;

  /// No description provided for @noRecentRoutes.
  ///
  /// In en, this message translates to:
  /// **'No recent routes'**
  String get noRecentRoutes;

  /// No description provided for @routeSearchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your recent route searches will appear here'**
  String get routeSearchesMessage;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteItem;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @selectBusNumber.
  ///
  /// In en, this message translates to:
  /// **'Select Bus Number'**
  String get selectBusNumber;

  /// No description provided for @complaintSubject.
  ///
  /// In en, this message translates to:
  /// **'Complaint Subject'**
  String get complaintSubject;

  /// No description provided for @complaintDescription.
  ///
  /// In en, this message translates to:
  /// **'Complaint Description'**
  String get complaintDescription;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaint;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get pleaseEnterValidMobile;

  /// No description provided for @pleaseSelectBusNumber.
  ///
  /// In en, this message translates to:
  /// **'Please select a bus number'**
  String get pleaseSelectBusNumber;

  /// No description provided for @pleaseEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get pleaseEnterSubject;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter complaint description'**
  String get pleaseEnterDescription;

  /// No description provided for @complaintSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted successfully'**
  String get complaintSubmitted;

  /// No description provided for @failedToSubmitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit complaint'**
  String get failedToSubmitComplaint;

  /// No description provided for @submitComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a Complaint'**
  String get submitComplaintTitle;

  /// No description provided for @helpImproveServices.
  ///
  /// In en, this message translates to:
  /// **'Help us improve our services by reporting issues'**
  String get helpImproveServices;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @cleanliness.
  ///
  /// In en, this message translates to:
  /// **'Cleanliness'**
  String get cleanliness;

  /// No description provided for @staffBehavior.
  ///
  /// In en, this message translates to:
  /// **'Staff Behavior'**
  String get staffBehavior;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @routeIssues.
  ///
  /// In en, this message translates to:
  /// **'Route Issues'**
  String get routeIssues;

  /// No description provided for @fareIssues.
  ///
  /// In en, this message translates to:
  /// **'Fare Issues'**
  String get fareIssues;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enter10DigitMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number'**
  String get enter10DigitMobile;

  /// No description provided for @busNumberExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 101, 205A'**
  String get busNumberExample;

  /// No description provided for @pleaseEnterBusNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter the bus number'**
  String get pleaseEnterBusNumber;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @briefDescription.
  ///
  /// In en, this message translates to:
  /// **'Brief description of the issue'**
  String get briefDescription;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @provideDetailedInfo.
  ///
  /// In en, this message translates to:
  /// **'Provide detailed information about the issue...'**
  String get provideDetailedInfo;

  /// No description provided for @pleaseProvideDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a description'**
  String get pleaseProvideDescription;

  /// No description provided for @descriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters long'**
  String get descriptionMinLength;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @busAlerts.
  ///
  /// In en, this message translates to:
  /// **'Bus Alerts'**
  String get busAlerts;

  /// No description provided for @busAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about service updates and delays'**
  String get busAlertsDesc;

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataStorage;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @freeUpStorage.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get freeUpStorage;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationAccess;

  /// No description provided for @locationAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow app to access your location for better services'**
  String get locationAccessDesc;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @selectLanguageDialog.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageDialog;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'gu',
    'hi',
    'mr',
    'pa',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
