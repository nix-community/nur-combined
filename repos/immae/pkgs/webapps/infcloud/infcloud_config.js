/*
InfCloud - the open source CalDAV/CardDAV Web Client
Copyright (C) 2011-2015
    Jan Mate <jan.mate@inf-it.com>
    Andrej Lezo <andrej.lezo@inf-it.com>
    Matej Mihalik <matej.mihalik@inf-it.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/


// NOTE: see readme.txt before you start to configure this client!


// NOTE: do not forget to execute the cache_update.sh script every time you
// update this configuration file or any other files (otherwise your browser
// will use the previous version of files stored in HTML5 cache). Alternatively
// you can update the cache.manifest manually - edit the second line beginning
// with "#V 20" to anything else (this file simple needs "some" change)


// Supported setup types (use ONE of them):
//   a.) globalAccountSettings => username and password is hardcoded
//       in config.js, automatic login without the login screen
//       - advantages: fast login process = no username/password is required
//       - disadvantages: username/password is visible in your config.js, so
//         this type of setup is recommended ONLY for intranet/home users
//   b.) globalNetworkCheckSettings => standard setup with login screen
//       - advantages: username/password is required (no visible
//         username/password in config.js)
//       - disadvantages: if a user enters wrong username/password then
//         the browser will show authentication popup window (it is NOT
//         possible to disable it in JavaScript; see the next option)
//   c.) globalNetworkAccountSettings => advanced setup with login screen
//       - advantages: no authentication popup if you enter wrong username/
//         password, dynamic XML configuration generator (you can generate
//         different configurations for your users /by modifying the "auth"
//         module configuration or the PHP code itself/)
//       - disadvantages: requires PHP >= 5.3 and additional configuration,
//         only basic http authentication is supported => always use https!
//
//
// What is a "principal URL"? => Check you server documentation!
//   - "principal URL" is NOT "collection URL"
//   - this client automatically detects collections for "principal URL"
//   - PROPER "principal URL" looks like:
//     https://server.com:8443/principals/users/USER/
//     https://server.com:8443/caldav.php/USER/
//   - INVALID principal URL looks like:
//     https://server.com:8443/principals/users/USER/collection/
//       => this is a collection URL
//     https://server.com:8443/caldav.php/USER/collection/
//       => this is a collection URL
//     https://server.com:8443/principals/users/USER
//       => missing trailing '/'
//     https://server.com:8443/caldav.php/USER
//       => missing trailing '/'
//     /caldav.php/USER/
//       => relative URL instead of full URL
//
//
// List of properties used in globalAccountSettings, globalNetworkCheckSettings
// and globalNetworkAccountSettings variables (+ in the "auth" module):
// - href
//   Depending on the setup type set the value to:
//   a.) globalAccountSettings: full "principal URL"
//   b.) globalNetworkCheckSettings: "principal URL" WITHOUT the "USER/" part
//   c.) globalNetworkAccountSettings: "full URL" to the "auth" directory
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings
// - userAuth
//   - userName
//     Set the username you want to login.
//   - userPassword
//     Set the password for the given username.
//   This property is supported in:
//     globalAccountSettings
// - timeOut
//   This option sets the timeout for jQuery .ajax call (in miliseconds).
//   Example:
//     timeOut: 90000
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings
// - lockTimeOut 
//   NOTE: used only if server supports LOCK requests
//   This option sets the LOCK timeout value if resource locking
//   is used (in miliseconds).
//   Example:
//     lockTimeOut: 10000
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only)
// - checkContentType
//   This option enables a content-type checking for server response.
//   If enabled then only objects with proper content-type are inserted
//   into the interface.
//   If you cannot see data in the interface you may try to disable it (useful
//   if your server returns wrong value in "propstat/prop/getcontenttype").
//   If undefined then content-type checking is enabled.
//   Examples:
//     checkContentType: true
//     checkContentType: false
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only)
// - settingsAccount
//   NOTE: server support for custom DAV properties is REQUIRED!
//   This option sets the account where the client properties such as:
//   loaded collections, enabled collections, ... are saved during
//   the logout and resource/collection synchronisation
//   NOTE: set it to true ONLY for ONE account!
//   Examples:
//     settingsAccount: true
//     settingsAccount: false
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only)
// - delegation
//   NOTE: server support for this functionality is REQUIRED!
//   This option allows you to load delegated (shared) collections.
//   If set to true (default) then delegation functionality is enabled,
//   and the interface allows you to load delegated collections.
//   If false then delegation functionality is completely disabled.
//   Examples:
//     delegation: true
//     delegation: false
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only)
// - additionalResources
//   This options sets the list of additional resources (e.g. shared resources
//   accessible by all users). If the server supports delegation (see
//   the delegation option above) there is no reason to use this option!
//   Supported values:
//   - array of URL encoded resource names (not collections), such as:
//     'company'
//     'shared_resource'
//   If empty (default) or undefined then shared resources are not loaded
//   using this option, but may be loaded using the delegation option.
//   Examples:
//     additionalResources=[]
//     additionalResources=['public', 'shared_resource']
//   This property is supported in:
//     globalNetworkCheckSettings
// - hrefLabel
//   This option sets the server name in the resource header (useful if
//   you want to see custom resource header above the collections).
//   You can use the following variables in the value:
//     %H = full hostname (including the port number)
//     %h = full hostname (without the port number)
//     %D = full domain name
//     %d = only the first and second level domain
//     %P = principal name
//     %p = principal name without the @domain.com part (if present)
//     %U = logged user name
//     %u = logged user name without the @domain.com part (if present)
//   If undefined, empty or or null then '%d/%p [%u]' is used.
//   Examples: 
//     hrefLabel: '%d/%p [%u]'
//     hrefLabel: '%D/%u'
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only)
// - forceReadOnly
//   This option sets the list of collections as "read-only".
//   Supported values:
//   - true
//     all collections will be "read-only"
//   - array of URL encoded
//     - collections, such as: 
//       '/caldav.php/user/calendar/'
//       '/caldav.php/user%40domain.com/calendar/'
//     - regexes, such as:
//       new RegExp('^/caldav.php/user/calendar[0-9]/$', 'i')
//     specifies the list of collections marked as "read-only"
//   If null (default) or undefined then server detected privileges are used.
//   Examples:
//     forceReadOnly: null
//     forceReadOnly: true
//     forceReadOnly: ['/caldav.php/user/calendar/', 
//                     '/caldav.php/user/calendar2/']
//     forceReadOnly: [new RegExp('^/.*/user/calendar[0-9]/$', 'i')]
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only, with
//       different syntax for regexes)
// - ignoreAlarms
//   This option sets list of calendar collections with disabled
//   alarm functionality.
//   Supported values:
//   - true
//     alarm functionality is disabled for all collections
//   - array of URL encoded
//     - collections, such as: 
//       '/caldav.php/user/calendar/'
//       '/caldav.php/user%40domain.com/calendar/'
//     - regexes, such as:
//       new RegExp('^/caldav.php/user/calendar[0-9]/$', 'i')
//     specifies the list of collections with disabled alarm functionality.
//   If false (default) or undefined then alarm functionality is enabled
//   for all collections.
//   Examples:
//     ignoreAlarms: true
//     ignoreAlarms: ['/caldav.php/user/calendar/', 
//                    '/caldav.php/user/calendar2/']
//     ignoreAlarms: [new RegExp('^/.*/user/calendar[0-9]/$', 'i')]
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only, with
//       different syntax for regexes)
// - backgroundCalendars
//   This options defines a list of background calendars. If there is
//   at least one event defined for the given day in a background calendar,
//   the background color for that day will be pink/light-red.
//   Supported values:
//   - array of URL encoded
//     - collections, such as: 
//       '/caldav.php/user/calendar/'
//       '/caldav.php/user%40domain.com/calendar/'
//     - regexes, such as:
//       new RegExp('^/caldav.php/user/calendar[0-9]/$', 'i')
//     specifies the list of background calendar collections.
//   Examples:
//     backgroundCalendars: ['/caldav.php/user/calendar/', 
//                           '/caldav.php/user/calendar2/']
//     backgroundCalendars: [new RegExp('^/.*/user/calendar[0-9]/$', 'i')]
//   This property is supported in:
//     globalAccountSettings
//     globalNetworkCheckSettings
//     globalNetworkAccountSettings (available in auth module only, with
//       different syntax for regexes)
// Special options not present in configuration examples:
// NOTE: use ONLY if you know what are you doing!
// - crossDomain
//   This option sets the crossDomain for jQuery .ajax call. If null (default)
//   then the value is autodetected /and the result is shown in the console/
// - withCredentials
//   This option sets the withCredentials for jQuery .ajax call. The default
//   value is false and there is NO REASON to change it to true!
//   NOTE: if true, Access-Control-Allow-Origin "*" (CORS header) not works!


// globalAccountSettings
// Use this option if you want to use automatic login (without a login
// screen) with hardcoded username/password in config.js. Otherwise use
// globalNetworkCheckSettings or globalNetworkAccountSettings (see below).
// NOTE: if this option is used the value must be an array of object(s).
// List of properties used in globalAccountSettings variable:
// - href
//   Set this option to the full "principal URL".
//   NOTE: the last character in the value must be '/'
// - userAuth
//   - userName
//     Set the username you want to login.
//   - userPassword
//     Set the password for the given username.
// NOTE: for description of other properties see comments at the beginning
// of this file.
// NOTE: for minimal/fast setup you need to set only the href and userAuth
// options. It is safe/recommended to keep the remaining options unchanged!
// Example:
//var globalAccountSettings=[
//	{
//		href: 'https://server1.com:8443/caldav.php/USERNAME1/',
//		userAuth:
//		{
//			userName: 'USERNAME1',
//			userPassword: 'PASSWORD1'
//		},
//		timeOut: 90000,
//		lockTimeOut: 10000,
//		checkContentType: true,
//		settingsAccount: true,
//		delegation: true,
//		hrefLabel: null,
//		forceReadOnly: null,
//		ignoreAlarms: false,
//		backgroundCalendars: []
//	},
//	{
//		href: 'https://server2.com:8443/caldav.php/USERNAME2/',
//		...
//		...
//	}
//];


// globalNetworkCheckSettings
// Use this option if you want to use standard login screen without
// hardcoded username/password in config.js (used by globalAccountSettings).
// NOTE: if this option is used the value must be an object.
// List of properties used in globalAccountSettings variable:
// - href
//   Set this option to the "principal URL" WITHOUT the "USERNAME/"
//   part (this options uses the username from the login screen).
//   NOTE: the last character in the value must be '/'
// NOTE: for description of other properties see comments at the beginning
// of this file.
// NOTE: for minimal/fast setup you need to set only the href option. It is
// safe/recommended to keep the remaining options unchanged!
// Example href values:
// OS X server http example (see misc/readme_osx.txt for server setup):
//   href: 'http://osx.server.com:8008/principals/users/'
// OS X server https example (see misc/readme_osx.txt for server setup):
//   href: 'https://osx.server.com:8443/principals/users/'
// Cyrus server https example:
//   href: 'https://cyrus.server.com/dav/principals/user/'
// Example:
// Davical example which automatically detects the protocol, server name,
// port, ... (client installed into Davical "htdocs" subdirectory;
// works "out of the box", no additional setup required):
var globalNetworkCheckSettings={
	href: location.protocol+'//'+location.hostname+
		(location.port ? ':'+location.port: '')+
		location.pathname.replace(RegExp('/+[^/]+/*(index\.html)?$'),'')+
		'/caldav.php/',
	timeOut: 90000,
	lockTimeOut: 10000,
	checkContentType: true,
	settingsAccount: true,
	delegation: true,
	additionalResources: [],
	hrefLabel: null,
	forceReadOnly: null,
	ignoreAlarms: false,
	backgroundCalendars: []
}


// globalNetworkAccountSettings
// Try this option ONLY if you have working setup using
// globalNetworkCheckSettings and want to fix the authentication popup
// window problem (if invalid username/password is entered)!
// If you use this option then your browser sends username/password to the PHP
// "auth" module ("auth" directory) instead of the DAV server itself.
// The "auth" module then validates your username/password against your server,
// and if the authentication is successful, then it sends back a configuration
// XML (requires additional configuration). The resulting XML is handled
// IDENTICALLY as the globalAccountSettings configuration option.
// NOTE: for the "auth" module configuration see readme.txt!
// NOTE: this option invokes a login screen and disallows access until
// the client gets correct XML configuration file from the server!
// List of properties used in globalNetworkAccountSettings variable:
// - href
//   Set this option to the "full URL" of the "auth" directory
//   NOTE: the last character in the value must be '/'
// NOTE: for description of other properties see comments at the beginning
// of this file.
// Example href values:
//   href: 'https://server.com/client/auth/'
// Example:
// Use this configuration if the "auth" module is located in the client
// installation subdirectory (default):
//var globalNetworkAccountSettings={
//	href: location.protocol+'//'+location.hostname+
//		(location.port ? ':'+location.port : '')+
//		location.pathname.replace(RegExp('index\.html$'),'')+
//		'auth/',
//	timeOut: 30000
//};


// globalUseJqueryAuth
// Use jQuery .ajax() auth or custom header for HTTP basic auth (default).
// Set this option to true if your server uses digest auth (note: you may
// experience auth popups on some browsers).
// If undefined (or empty), custom header for HTTP basic auth is used.
// Example:
//var globalUseJqueryAuth=false;


// globalBackgroundSync
// Enable background synchronization even if the browser window/tab has no
// focus.
// If false, synchronization is performed only if the browser window/tab
// is focused. If undefined or not false, then background sync is enabled.
// Example:
var globalBackgroundSync=true;


// globalSyncResourcesInterval
// This option defines how often (in miliseconds) are resources/collections
// asynchronously synchronized.
// Example:
var globalSyncResourcesInterval=120000;


// globalEnableRefresh
// This option enables or disables the manual synchronization button in
// the interface. If this option is enabled then users can perform server
// synchronization manually. Enabling this option may cause high server
// load (even DDOS) if users will try to manually synchronize data too
// often (instead of waiting for the automatic synchronization).
// If undefined or false, the synchronization button is disabled.
// NOTE: enable this option only if you really know what are you doing!
// Example:
var globalEnableRefresh=false;


// globalEnableKbNavigation
// Enable basic keyboard navigation using arrow keys?
// If undefined or not false, keyboard navigation is enabled.
// Example:
var globalEnableKbNavigation=true;


// globalSettingsType
// Where to store user settings such as: active view, enabled/selected
// collections, ... (the client store them into DAV property on the server).
// NOTE: not all servers support storing DAV properties (some servers support
// only subset /or none/ of these URLs).
// Supported values:
// - 'principal-URL', '', null or undefined (default) => settings are stored
//   to principal-URL (recommended for most servers)
// - 'addressbook-home-set' => settings are are stored to addressbook-home-set
// - 'calendar-home-set' => settings are stored to calendar-home-set
// Example:
//var globalSettingsType='';


// globalCrossServerSettingsURL
// Settings such as enabled/selected collections are stored on the server
// (see the previous option) in form of full URL
// (e.g.: https://user@server:port/principal/collection/), but even if this
// approach is "correct" (you can use the same principal URL with multiple
// different logins, ...) it causes a problem if your server is accessible
// from multiple URLs (e.g. http://server/ and https://server/). If you want
// to store only the "principal/collection/" part of the URL (instead of the
// full URL) then enable this option.
// Example:
//var globalCrossServerSettingsURL=false;


// globalInterfaceLanguage
// Default interface language (note: this option is case sensitive):
//   cs_CZ (Čeština [Czech])
//   da_DK (Dansk [Danish]; thanks Niels Bo Andersen)
//   de_DE (Deutsch [German]; thanks Marten Gajda and Thomas Scheel)
//   en_US (English [English/US])
//   es_ES (Español [Spanish]; thanks Damián Vila)
//   fr_FR (Français [French]; thanks John Fischer)
//   it_IT (Italiano [Italian]; thanks Luca Ferrario)
//   ja_JP (日本語 [Japan]; thanks Muimu Nakayama)
//   hu_HU (Magyar [Hungarian])
//   nl_NL (Nederlands [Dutch]; thanks Johan Vromans)
//   sk_SK (Slovenčina [Slovak])
//   tr_TR (Türkçe [Turkish]; thanks Selcuk Pultar)
//   ru_RU (Русский [Russian]; thanks Александр Симонов)
//   uk_UA (Українська [Ukrainian]; thanks Serge Yakimchuck)
//   zh_CN (中国 [Chinese]; thanks Fandy)
// Example:
var globalInterfaceLanguage='fr_FR';


// globalInterfaceCustomLanguages
// If defined and not empty then only languages listed here are shown
// at the login screen, otherwise (default) all languages are shown
// NOTE: values in the array must refer to an existing localization
// (see the option above)
// Example:
//   globalInterfaceCustomLanguages=['en_US', 'sk_SK'];
var globalInterfaceCustomLanguages=[];


// globalSortAlphabet
// Use JavaScript localeCompare() or custom alphabet for data sorting.
// Custom alphabet is used by default because JavaScript localeCompare()
// not supports collation and often returns "wrong" result. If set to null
// then localeCompare() is used.
// Example:
//   var globalSortAlphabet=null;
var globalSortAlphabet=' 0123456789'+
	'AÀÁÂÄÆÃÅĀBCÇĆČDĎEÈÉÊËĒĖĘĚFGĞHIÌÍÎİÏĪĮJKLŁĹĽMNŃÑŇOÒÓÔÖŐŒØÕŌ'+
	'PQRŔŘSŚŠȘșŞşẞTŤȚțŢţUÙÚÛÜŰŮŪVWXYÝŸZŹŻŽ'+
	'aàáâäæãåābcçćčdďeèéêëēėęěfgğhiìíîïīįıjklłĺľmnńñňoòóôöőœøõō'+
	'pqrŕřsśšßtťuùúûüűůūvwxyýÿzźżžАБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЮЯ'+
	'Ьабвгґдеєжзиіїйклмнопрстуфхцчшщюяь';


// globalSearchTransformAlphabet
// To support search without diacritics (e.g. search for 'd' will find: 'Ď', 'ď')
// it is required to define something like "character equivalence".
// key = regex text, value = search character
// Example:
var globalSearchTransformAlphabet={
	'[ÀàÁáÂâÄäÆæÃãÅåĀā]': 'a', '[ÇçĆćČč]': 'c', '[Ďď]': 'd',
	'[ÈèÉéÊêËëĒēĖėĘęĚě]': 'e', '[Ğğ]': 'g', '[ÌìÍíÎîİıÏïĪīĮį]': 'i',
	'[ŁłĹĺĽľ]': 'l', '[ŃńÑñŇň]': 'n', '[ÒòÓóÔôÖöŐőŒœØøÕõŌō]': 'o',
	'[ŔŕŘř]': 'r', '[ŚśŠšȘșŞşẞß]': 's', '[ŤťȚțŢţ]': 't',
	'[ÙùÚúÛûÜüŰűŮůŪū]': 'u', '[ÝýŸÿ]': 'y', '[ŹźŻżŽž]': 'z'
};

// globalResourceAlphabetSorting
// If more than one resource (server account) is configured, sort the
// resources alphabetically?
// Example:
var globalResourceAlphabetSorting=true;


// globalNewVersionNotifyUsers
// Update notification will be shown only to users with login names defined
// in this array.
// If undefined (or empty), update notifications will be shown to all users.
// Example:
//   globalNewVersionNotifyUsers=['admin', 'peter'];
var globalNewVersionNotifyUsers=[];


// globalDatepickerFormat
// Set the datepicker format (see 
// http://docs.jquery.com/UI/Datepicker/formatDate for valid values).
// NOTE: date format is predefined for each localization - use this option
// ONLY if you want to use custom date format (instead of the localization
// predefined one).
// Example:
//var globalDatepickerFormat='dd.mm.yy';
var globalDatepickerFormat='yy-mm-dd';


// globalDatepickerFirstDayOfWeek
// Set the datepicker first day of the week: Sunday is 0, Monday is 1, etc.
// Example:
var globalDatepickerFirstDayOfWeek=1;


// globalHideInfoMessageAfter
// How long are information messages (such as: success, error) displayed
// (in miliseconds).
// Example:
var globalHideInfoMessageAfter=1800;


// globalEditorFadeAnimation
// Set the editor fade in/out animation duration when editing or saving data
// (in miliseconds).
// Example:
var globalEditorFadeAnimation=666;




// ******* CalDAV (CalDavZAP) related settings ******* //

// globalEventStartPastLimit, globalEventStartFutureLimit, globalTodoPastLimit
// Number of months pre-loaded from past/future in advance for calendars
// and todo lists (if null then date range synchronization is disabled).
// NOTE: interval synchronization is used only if your server supports
// sync-collection REPORT (e.g. DAViCal).
// NOTE: if you experience problems with data loading and your server has
// no time-range filtering support set these variables to null.
// Example:
var globalEventStartPastLimit=3;
var globalEventStartFutureLimit=3;
var globalTodoPastLimit=1;


// globalLoadedCalendarCollections
// This option sets the list of calendar collections (down)loaded after login.
// If empty then all calendar collections for the currently logged user are
// loaded.
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
var globalLoadedCalendarCollections=[];


// globalLoadedTodoCollections
// This option sets the list of todo collections (down)loaded after login.
// If empty then all todo collections for the currently logged user are loaded.
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
var globalLoadedTodoCollections=[];


// globalActiveCalendarCollections
// This options sets the list of calendar collections checked (enabled
// checkbox => data visible in the interface) by default after login.
// If empty then all loaded calendar collections for the currently logged
// user are checked.
// NOTE: only already (down)loaded collections can be checked (see 
// the globalLoadedCalendarCollections option).
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
var globalActiveCalendarCollections=[];


// globalActiveTodoCollections
// This options sets the list of todo collections checked (enabled
// checkbox => data visible in the interface) by default after login.
// If empty then all loaded todo collections for the currently logged
// user are checked.
// NOTE: only already (down)loaded collections can be checked (see 
// the globalLoadedTodoCollections option).
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
var globalActiveTodoCollections=[];


// globalCalendarSelected
// This option sets which calendar collection will be pre-selected
// (if you create a new event) by default after login.
// The value must be URL encoded path to a calendar collection,
// for example: 'USER/calendar/'
// If empty or undefined then the first available calendar collection
// is selected automatically.
// NOTE: only already (down)loaded collections can be pre-selected (see
// the globalLoadedCalendarCollections option).
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
//var globalCalendarSelected='';


// globalTodoCalendarSelected
// This option sets which todo collection will be pre-selected
// (if you create a new todo) by default after login.
// The value must be URL encoded path to a todo collection,
// for example: 'USER/todo_calendar/'
// If empty or undefined then the first available todo collection
// is selected automatically.
// NOTE: only already (down)loaded collections can be pre-selected (see 
// the globalLoadedTodoCollections option).
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
//var globalTodoCalendarSelected='';


// globalActiveView
// This options sets the default fullcalendar view option (the default calendar
// view after the first login).
// Supported values:
// - 'month'
// - 'multiWeek'
// - 'agendaWeek'
// - 'agendaDay'
// NOTE: we use custom and enhanced version of fullcalendar!
// Example:
var globalActiveView='multiWeek';


// globalOpenFormMode
// Open new event form on 'single' or 'double' click.
// If undefined or not 'double', then 'single' is used.
// Example:
var globalOpenFormMode='double';


// globalTodoListFilterSelected
// This options sets the list of filters in todo list that are selected
// after login.
// Supported options:
// - 'filterAction'
// - 'filterProgress' (available only if globalAppleRemindersMode is disabled)
// - 'filterCompleted'
// - 'filterCanceled' (available only if globalAppleRemindersMode is disabled)
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
var globalTodoListFilterSelected=['filterAction', 'filterProgress'];


// globalCalendarStartOfBusiness, globalCalendarEndOfBusiness
// These options set the start and end of business hours with 0.5 hour
// precision. Non-business hours are faded out in the calendar interface.
// If both variables are set to the same value then no fade out occurs.
// Example:
var globalCalendarStartOfBusiness=8;
var globalCalendarEndOfBusiness=17;


// globalDefaultEventDuration
// This option sets the default duration (in minutes) for newly created events.
// If undefined or null, globalCalendarEndOfBusiness value will be taken as
// a default end time instead.
// Example:
var globalDefaultEventDuration=120;


// globalAMPMFormat
// This option enables to use 12 hours format (AM/PM) for displaying time.
// NOTE: time format is predefined for each localization - use this option
// ONLY if you want to use custom time format (instead of the localization
// predefined one).
// Example:
//var globalAMPMFormat=false;


// globalTimeFormatBasic
// This option defines the time format information for events in month and
// multiweek views. If undefined or null then default value is used.
// If defined as empty string no time information is shown in these views.
// See http://arshaw.com/fullcalendar/docs/utilities/formatDate/ for exact
// formating rules.
// Example:
//var globalTimeFormatBasic='';


// globalTimeFormatAgenda
// This option defines the time format information for events in day and
// week views. If undefined or null then default value is used.
// If defined as empty string no time information is shown in these views.
// See http://arshaw.com/fullcalendar/docs/utilities/formatDate/ for exact
// formating rules.
// Example:
//var globalTimeFormatAgenda='';


// globalDisplayHiddenEvents
// This option defined whether events from unechecked calendars are displayed
// with certain transparency (true) or completely hidden (false).
// Example:
var globalDisplayHiddenEvents=false;


// globalTimeZoneSupport
// This option enables timezone support in the client.
// NOTE: timezone cannot be specified for all-day events because these don't
// have start and end time.
// If this option is disabled then local time is used.
// Example:
var globalTimeZoneSupport=true;


// globalTimeZone
// If timezone support is enabled, this option sets the default timezone.
// See timezones.js or use the following command to get the list of supported
// timezones (defined in timezones.js):
// grep "'[^']\+': {" timezones.js | sed -Ee "s#(\s*'|':\s*\{)##g"
// Example:
var globalTimeZone='Europe/Paris';


// globalTimeZonesEnabled
// This option sets the list of available timezones in the interface (for the 
// list of supported timezones see the comment for the previous configuration
// option).
// NOTE: if there is at least one event/todo with a certain timezone defined,
// that timezone is enabled (even if it is not present in this list).
// Example:
//   var globalTimeZonesEnabled=['America/New_York', 'Europe/Berlin'];	
var globalTimeZonesEnabled=[];


// globalRewriteTimezoneComponent
// This options sets whether the client will enhance/replace (if you edit an
// event or todo) the timezone information using the official IANA timezone
// database information (recommended).
// Example:
var globalRewriteTimezoneComponent=true;


// globalRemoveUnknownTimezone
// This options sets whether the client will remove all non-standard timezone
// names from events and todos (if you edit an event or todo)
// (e.g.: /freeassociation.sourceforge.net/Tzfile/Europe/Vienna)
// Example:
var globalRemoveUnknownTimezone=false;


// globalShowHiddenAlarms
// This option sets whether the client will show alarm notifications for
// unchecked calendars. If this option is enabled and you uncheck a calendar
// in the calendar list, alarm notifications will be temporary disabled for
// unchecked calendar(s).
// Example:
var globalShowHiddenAlarms=false;


// globalIgnoreCompletedOrCancelledAlarms
// This options sets whether the client will show alarm notifications for
// already completed or cancelled todos. If enabled then alarm notification
// for completed and cancelled todos are disabled.
// Example:
var globalIgnoreCompletedOrCancelledAlarms=true;


// globalMozillaSupport
// Mozilla automatically treats custom repeating event calculations as if
// the start day of the week is Monday, despite what day is chosen in settings.
// Set this variable to true to use the same approach, ensuring compatible
// event rendering in special cases.
// Example:
var globalMozillaSupport=false;


// globalCalendarColorPropertyXmlns
// This options sets the namespace used for storing the "calendar-color"
// property by the client.
// If true, undefined (or empty) "http://apple.com/ns/ical/" is used (Apple
// compatible). If false, then the calendar color modification functionality
// is completely disabled.
// Example:
//var globalCalendarColorPropertyXmlns=true;


// globalWeekendDays
// This option sets the list of days considered as weekend days (these
// are faded out in the calendar interface). Non-weekend days are automatically
// considered as business days.
// Sunday is 0, Monday is 1, etc.
// Example:
var globalWeekendDays=[0, 6];


// globalAppleRemindersMode
// If this option is enabled then then client will use the same approach
// for handling repeating reminders (todos) as Apple. It is STRONGLY
// recommended to enabled this option if you use any Apple clients for
// reminders (todos).
// Supported options:
// - 'iOS6'
// - 'iOS7'
// - true (support of the latest iOS version - 'iOS8')
// - false
// If this option is enabled:
// - RFC todo support is SEVERELY limited and the client mimics the behaviour
//   of Apple Reminders.app (to ensure maximum compatibility)
// - when a single instance of repeating todo is edited, it becomes an
//   autonomous non-repeating todo with NO relation to the original repeating
//   todo
// - capabilities of repeating todos are limited - only the first instance
//   is ever visible in the interface
// - support for todo DTSTART attribute is disabled
// - support for todo STATUS attribute other than COMPLETED and NEEDS-ACTION
//   is disabled
// - [iOS6 only] support for LOCATION and URL attributes is disabled
// Example:
var globalAppleRemindersMode=true;


// globalSubscribedCalendars
// This option specifies a list of remote URLs to ics files (e.g.: used
// for distributing holidays information). Subscribed calendars are
// ALWAYS read-only. Remote servers where ics files are hosted MUST
// return proper CORS headers (see readme.txt) otherwise this functionality
// will not work!
// NOTE: subsribed calendars are NOT "shared" calendars. For "shared"
// calendars see the delegation option in globalAccountSettings,
// globalNetworkCheckSettings and globalNetworkAccountSettings.
// List of properties used in globalSubscribedCalendars variable:
// - hrefLabel
//   This options defines the header string above the subcsribed calendars.
// - calendars
//   This option specifies an array of remote calendar objects with the
//   following properties:
//   - href
//     Set this option to the "full URL" of the remote calendar
//   - userAuth
//     NOTE: keep empty if remote authentication is not required!
//     - userName
//       Set the username you want to login.
//     - userPassword
//       Set the password for the given username.
//   - typeList
//     Set the list of objects you want to process from remote calendars;
//     two options are available:
//     - 'vevent' (show remote events in the interface) 
//     - 'vtodo' (show remote todos in the interface) 
//   - ignoreAlarm
//     Set this option to true if you want to disable alarm notifications
//     from the remote calendar.
//   - displayName
//     Set this option to the name of the calendar you want to see
//     in the interface.
//   - color
//     Set the calendar color you want to see in the interface.
// Example:
//var globalSubscribedCalendars={
//	hrefLabel: 'Subscribed',
//	calendars: [
//		{
//			href: 'http://something.com/calendar.ics',
//			userAuth: {
//				userName: '',
//				userPassword: ''
//			},
//			typeList: ['vevent', 'vtodo'],
//			ignoreAlarm: true,
//			displayName: 'Remote Calendar 1',
//			color: '#ff0000'
//		},
//		{
//			href: 'http://calendar.com/calendar2.ics',
//			...
//			...
//		}
//	]
//};



// ******* CardDAV (CardDavMATE) related settings ******* //


// globalLoadedAddressbookCollections
// This option sets the list of addressbook collections (down)loaded after
// login. If empty then all addressbook collections for the currently logged
// user are loaded.
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
var globalLoadedAddressbookCollections=[];


// globalActiveAddressbookCollections
// This options sets the list of addressbook collections checked (enabled
// checkbox => data visible in the interface) by default after login.
// If empty then all loaded addressbook collections for the currently logged
// user are checked.
// NOTE: only already (down)loaded collections can be checked (see
// the globalLoadedAddressbookCollections option).
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
var globalActiveAddressbookCollections=[];


// globalAddressbookSelected
// This option sets which addressbook collection will be pre-selected
// (if you create a new contact) by default after login.
// The value must be URL encoded path to an addressbook collection,
// for example: 'USER/addressbook/'
// If empty or undefined then the first available addressbook collection
// is selected automatically.
// NOTE: only already (down)loaded collections can be pre-selected (see
// the globalLoadedAddressbookCollections option).
// NOTE: settings stored on the server (see settingsAccount) overwrite this
// option.
// Example:
//var globalAddressbookSelected='';


// globalCompatibility
// This options is reserved for various compatibility settings.
// NOTE: if this option is used the value must be an object.
// Currently there is only one supported option:
// - anniversaryOutputFormat
//   Different clients use different (and incompatible) approach
//   to store anniversary date in vCards. Apple stores this attribute as:
//     itemX.X-ABDATE;TYPE=pref:2000-01-01\r\n
//     itemX.X-ABLabel:_$!<Anniversary>!$_\r\n'
//   other clients store this attribute as:
//     X-ANNIVERSARY:2000-01-01\r\n
//   Choose 'apple' or 'other' (lower case) for your 3rd party client
//   compatibility. You can chose both: ['apple', 'other'], but it may
//   cause many problems in the future, for example: duplicate anniversary
//   dates, invalid/old anniversary date in your clients, ...)
//   Examples:
//     anniversaryOutputFormat: ['other']
//     anniversaryOutputFormat: ['apple', 'other']
// Example:
var globalCompatibility={anniversaryOutputFormat: ['apple']};


// globalUriHandler{Tel,Email,Url,Profile}
// These options set the URI handlers for TEL, EMAIL, URL and X-SOCIALPROFILE
// vCard attributes. Set them to null (or comment out) to disable.
// NOTE: for globalUriHandlerTel is recommended to use 'tel:', 'callto:'
// or 'skype:'. The globalUriHandlerUrl value is used only if no URI handler
// is defined in the URL.
// NOTE: it is safe to keep these values unchanged!
// Example:
var globalUriHandlerTel='tel:';
var globalUriHandlerEmail='mailto:';
var globalUriHandlerUrl='http://';
var globalUriHandlerProfile={
	'twitter': 'http://twitter.com/%u',
	'facebook': 'http://www.facebook.com/%u',
	'flickr': 'http://www.flickr.com/photos/%u',
	'linkedin': 'http://www.linkedin.com/in/%u',
	'myspace': 'http://www.myspace.com/%u',
	'sinaweibo': 'http://weibo.com/n/%u'
};


// globalDefaultAddressCountry
// This option sets the default country for new address fields.
// See common.js or use the following command to get the list of
// all supported country codes (defined in common.js):
// grep -E "'[a-z]{2}':\s+\[" common.js | sed -Ee 's#^\s+|\s+\[\s+# #g'
// Example:
var globalDefaultAddressCountry='fr';


// globalAddressCountryEquivalence
// This option sets the processing of the country field specified
// in the vCard ADR attribute.
// By default the address field in vCard looks like:
//   ADR;TYPE=WORK:;;1 Waters Edge;Baytown;LA;30314;USA\r\n
// what cause a problem, because the country field is a plain
// text and can contain any value, e.g.:
//   USA
//   United States of America
//   US
// and because the address format can be completely different for
// each country, e.g.:
//   China address example:
//     [China]
//     [Province] [City]
//     [Street]
//     [Postal]
//   Japan address example:
//     [Postal]
//     [Prefecture] [County/City]
//     [Further Divisions]
//     [Japan]
// the client needs to correctly detect the country from the ADR
// attribute. Apple solved this problem by using:
//   item1.ADR;TYPE=WORK:;;1 Waters Edge;Baytown;LA;30314;USA\r\n
//   item1.X-ABADR:us\r\n
// where the second "related" attribute defines the country code
// for the ADR attribute. This client uses the same approach, but
// if the vCard is created by 3rd party clients and the X-ABADR
// is missing, it is possible to define additional "rules" for
// country matching. These rules are specied by the country code
// (for full list of country codes see the comment for pre previous
// option) and a case insensitive regular expression (which matches
// the plain text value in the country field).
// NOTE: if X-ABADR is not present and the country not matches any
// country defined in this option, then globalDefaultAddressCountry
// is used by default.
// Example:
var globalAddressCountryEquivalence=[
	{country: 'de', regex: '^\\W*Deutschland\\W*$'},
	{country: 'sk', regex: '^\\W*Slovensko\\W*$'}
];


// globalAddressCountryFavorites
// This option defines the list of countries which are shown at the top
// of the country list in the interface (for full list of country codes
// see the comment for pre globalDefaultAddressCountry option).
// Example:
//   var globalAddressCountryFavorites=['de','sk'];
var globalAddressCountryFavorites=[];


// globalAddrColorPropertyXmlns
// This options sets the namespace used for storing the "addressbook-color"
// property by the client.
// If true, undefined (or empty) "http://inf-it.com/ns/ab/" is used.
// If false, then the addressbook color modification functionality
// is completely disabled, and addressbook colors in the interface are
// generated automatically.
// Example:
//var globalAddrColorPropertyXmlns=true;


// globalContactStoreFN
// This option specifies how the FN (formatted name) is stored into vCard.
// The value for this options must be an array of strings, that can contain
// the following variables:
//   prefix
//   last
//   middle
//   first
//   suffix
// The string element of the array can contain any other characters (usually
// space or colon). Elements are added into FN only if the there is
// a variable match, for example if:
//     last='Lastname'
//     first='Firstname'
//     middle='' (empty)
//   and this option is set to:
//     ['last', ' middle', ' first'] (space in the second and third element)
//   the resulting value for FN will be: 'Lastname Firstname' and not
//   'Lastname  Firstname' (two spaces), because the middle name is empty (so
//   the second element is completely ignored /not added into FN/).
// NOTE: this attribute is NOT used by this client, and it is also NOT
// possible to directly edit it in the interface.
// Examples:
//   var globalContactStoreFN=[' last', ' middle', ' first'];
//   var globalContactStoreFN=['last', ', middle', ' ,first'];
var globalContactStoreFN=['prefix',' last',' middle',' first',' suffix'];


// globalGroupContactsByCompanies
// This options specifies how contacts are grouped in the interface.
// By default the interface looks like (very simple example):
//   A
//    Adams Adam
//    Anderson Peter
//   B
//    Brown John
//    Baker Josh
// if grouped by company/deparment the result is:
//   Company A [Department X]
//    Adams Adam
//    Brown John
//   Company B [Department Y]
//    Anderson Peter
//    Baker Josh
// If this option is set to true contacts are grouped by company/department,
// otherwise (default) contacts are grouped by letters of the alphabet.
// If undefined or not true, grouping by alphabet letters is used.
// NOTE: see also the globalCollectionDisplay option below.
var globalGroupContactsByCompanies=false;


// globalCollectionDisplay
// This options specifies how data columns in the contact list are displayed.
//
// NOTE: columns are displayed ONLY if there is enought horizontal place in
// the browser window (e.g. if you define 5 columns here, but your browser
// window is not wide enough, you will see only first 3 columns instead of 5).
//
// NOTE: see the globalContactDataMinVisiblePercentage option which defines the
// width for columns.
//
// The value must be an array of columns, where each column is represented by
// an object with the following properties:
//   label => the value of this option is a string used as column header
//     You can use the following localized variables in the label string:
//     - {Name}
//     - {FirstName}
//     - {LastName}
//     - {MiddleName}
//     - {NickName}
//     - {Prefix}
//     - {Suffix}
//     - {BirthDay}
//     - {PhoneticLastName}
//     - {PhoneticFirstName}
//     - {JobTitle}
//     - {Company}
//     - {Department}
//     - {Categories}
//     - {NoteText}
//     - {Address}, {AddressWork}, {AddressHome}, {AddressOther}
//     - {Phone}, {PhoneWork}, {PhoneHome}, {PhoneCell}, {PhoneMain},
//       {PhonePager}, {PhoneFax}, {PhoneIphone}, {PhoneOther}
//     - {Email}, {EmailWork}, {EmailHome}, {EmailMobileme}, {EmailOther}
//     - {URL}, {URLWork}, {URLHome}, {URLHomepage}, {URLOther}
//     - {Dates}, {DatesAnniversary}, {DatesOther}
//     - {Related}, {RelatedManager}, {RelatedAssistant}, {RelatedFather},
//       {RelatedMother}, {RelatedParent}, {RelatedBrother}, {RelatedSister},
//       {RelatedChild}, {RelatedFriend}, {RelatedSpouse}, {RelatedPartner},
//       {RelatedOther}
//     - {Profile}, {ProfileTwitter}, {ProfileFacebook}, {ProfileFlickr},
//       {ProfileLinkedin}, {ProfileMyspace}, {ProfileSinaweibo}
//     - {IM}, {IMWork}, {IMHome}, {IMMobileme}, {IMOther}, {IMAim}, {IMIcq},
//       {IMIrc}, {IMJabber}, {IMMsn}, {IMYahoo}, {IMFacebook}, {IMGadugadu},
//       {IMGoogletalk}, {IMQq}, {IMSkype}
//   value => the value of this option is an array of format strings, or
//     an object with the following properties:
//     - company (used for company contacts)
//     - personal (used for user contacts)
//     where the value of these properties is an array of format strings used
//     for company or user contacts (you can have different values in the same
//     column for personal and company contacts).
//     You can use the following simple variables in the format string:
//     - {FirstName}
//     - {LastName}
//     - {MiddleName}
//     - {NickName}
//     - {Prefix}
//     - {Suffix}
//     - {BirthDay}
//     - {PhoneticLastName}
//     - {PhoneticFirstName}
//     - {JobTitle}
//     - {Company}
//     - {Department}
//     - {Categories}
//     - {NoteText}
//     You can also use parametrized variables, where the parameter is enclosed
//     in square bracket. Paramatrized variables are useful to extract data
//     such as home phone {Phone[type=home]}, extract the second phone number
//     {Phone[:1]} (zero based indexing) or extract the third home phone number
//     {Phone[type=home][:2]} from the vCard.
//     NOTE: if the parametrized variable matches multiple items, e.g.:
//     {Phone[type=work]} (if the contact has multiple work phones) then the
//     first one is used!
//
//     The following parametrized variables are supported (note: you can use
//     all of them also without parameters /the first one will be used/):
//     - {Address[type=XXX]} or {Address[:NUM]} or {Address[type=XXX][:NUM]}
//       where supported values for XXX are:
//       - work
//       - home
//       - other
//       - any other custom value
//     - {Phone[type=XXX]} or {Phone[:NUM]} or {Phone[type=XXX][:NUM]}
//       where supported values for XXX are:
//       - work
//       - home
//       - cell
//       - main
//       - pager
//       - fax
//       - iphone
//       - other
//       - any other custom value
//     - {Email[type=XXX]} or {Email[:NUM]} or {Email[type=XXX][:NUM]}
//       where supported values for XXX are:
//       - work
//       - home
//       - mobileme
//       - other
//       - any other custom value
//     - {URL[type=XXX]} or {URL[:NUM]} or {URL[type=XXX][:NUM]}
//       where supported values for XXX are:
//       - work
//       - home
//       - homepage
//       - other
//       - any other custom value
//     - {Dates[type=XXX]} or {Dates[:NUM]} or {Dates[type=XXX][:NUM]}
//       where supported values for XXX are:
//       - anniversary
//       - other
//       - any other custom value
//     - {Related[type=XXX]} or {Related[:NUM]} or {Related[type=XXX][:NUM]}
//       where supported values for XXX are:
//       - manager
//       - assistant
//       - father
//       - mother
//       - parent
//       - brother
//       - sister
//       - child
//       - friend
//       - spouse
//       - partner
//       - other
//       - any other custom value
//     - {Profile[type=XXX]} or {Profile[:NUM]} or {Profile[type=XXX][:NUM]}
//       where supported values for XXX are:
//       - twitter
//       - facebook
//       - flickr
//       - linkedin
//       - myspace
//       - sinaweibo
//       - any other custom value
//     - {IM[type=XXX]} or {IM[service-type=YYY]} or {IM[:NUM]}
//       where supported values for XXX are:
//       - work
//       - home
//       - mobileme
//       - other
//       - any other custom value
//       and supported values for YYY are:
//       - aim
//       - icq
//       - irc
//       - jabber
//       - msn
//       - yahoo
//       - facebook
//       - gadugadu
//       - googletalk
//       - qq
//       - skype
//       - any other custom value
//
//   NOTE: if you want to use the "any other custom value" option (for XXX
//   or YYY above) you MUST double escape the following characters:
//     =[]{}\
//   for example:
//   - for profile type "=XXX=" use: '{Profile[type=\\=XXX\\=]}'
//   - for profile type "\XXX\" use: '{Profile[type=\\\\XXX\\\\]}'
//
//   NOTE: if you want to use curly brackets in the format string you must
//   double escape it, e.g.: ['{Company}', '\\{{Department}\\}']
//
//   The format string (for the value option) is an array to allow full
//   customization of the interface. For example if:
//     value: ['{LastName} {MiddleName} {FirstName}']
//   and the person has no middle name, then the result in the column
//   will be (without quotes):
//     "Parker  Peter" (note: two space characters)
//   but if you use:
//     value: ['{LastName}', ' {MiddleName}', ' {FirstName}']
//   then the result will be (without quotes):
//     "Parker Peter" (note: only one space character)
//   The reason is that only those elements of the array are appended
//   into the result where non-empty substitution was performed (so the
//   ' {MiddleName}' element in this case is ignored, because the person
//   in the example above has no /more precisely has empty/ middle name).
//
// Examples:
// To specify two columns (named "Company" and "Department / LastName"),
// where the first will display the company name, and the second will display
// department for company contacts (with "Dep -" prefix), and lastname for
// personal contacts (with "Name -" prefix) use:
// var globalCollectionDisplay=[
// 	{
// 		label: 'Company',
// 		value: ['{Company}']
// 	},
// 	{
// 		label: 'Department / LastName',
// 		value: {
// 			company: ['Dep - {Department}'],
// 			personal: ['Name - {LastName}']
// 		}
// 	}
// ];
// To specify 3 columns (named "Categories", "URL" and "IM"), where the first
// will display categories, second will display the third work URL, and third
// will display ICQ IM use:
// var globalCollectionDisplay=[
// 	{
// 		label: 'Categories',
// 		value: ['{Categories}']
// 	},
// 	{
// 		label: 'URL',
// 		value: ['{URL[type=WORK][:2]}']
// 	},
// 	{
// 		label: 'IM',
// 		value: ['{IM[service-type=ICQ]}']
// 	}
// ];
//
// Recommended settings if globalGroupContactsByCompanies
// is set to false:
// var globalCollectionDisplay=[
// 	{
// 		label: '{Name}',
// 		value: ['{LastName}', ' {MiddleName}', ' {FirstName}']
// 	},
// 	{
// 		label: '{Company} [{Department}]',
// 		value: ['{Company}', ' [{Department}]']
// 	},
// 	{
// 		label: '{JobTitle}',
// 		value: ['{JobTitle}']
// 	},
// 	{
// 		label: '{Email}',
// 		value: ['{Email[:0]}']
// 	},
// 	{
// 		label: '{Phone} 1',
// 		value: ['{Phone[:0]}']
// 	},
// 	{
// 		label: '{Phone} 2',
// 		value: ['{Phone[:1]}']
// 	},
// 	{
// 		label: '{NoteText}',
// 		value: ['{NoteText}']
// 	}
// ];
//
// Recommended settings if globalGroupContactsByCompanies
// is set to true:
// var globalCollectionDisplay=[
// 	{
// 		label: '{Name}',
// 		value: {
// 			personal: ['{LastName}', ' {MiddleName}', ' {FirstName}'],
// 			company: ['{Company}', ' [{Department}]']
// 		}
// 	},
// 	{
// 		label: '{JobTitle}',
// 		value: ['{JobTitle}']
// 	},
// 	{
// 		label: '{Email}',
// 		value: ['{Email[:0]}']
// 	},
// 	{
// 		label: '{Phone} 1',
// 		value: ['{Phone[:0]}']
// 	},
// 	{
// 		label: '{Phone} 2',
// 		value: ['{Phone[:1]}']
// 	},
// 	{
// 		label: '{NoteText}',
// 		value: ['{NoteText}']
// 	}
// ];
//
// NOTE: if left undefined, the recommended settings will be used.


// globalCollectionSort
// This options sets the ordering of contacts in the interface. In general
// contacts are ordered alphabetically by an internal "sort string" which
// is created for each contact. Here you can specify how this internal string
// is created. The value is a simple array holding only the values from the
// value property defined in the globalCollectionDisplay option.
// If undefined, the definition from globalCollectionDisplay is used.
// Example:
// var globalCollectionSort = [
// 	['{LastName}'],
// 	['{FirstName}'],
// 	['{MiddleName}'],
// 	{
// 		company: ['{Categories}'],
// 		personal: ['{Company}']
// 	}
// ];
var globalCollectionSort=[
  ['{LastName}'],
  ['{FirstName}'],
  ['{MiddleName}']
];


// globalContactDataMinVisiblePercentage
// This option defines how the width for columns are computed. If you set
// it to 1 then 100% of all data in the column will be visible (the column
// width is determined by the longest string in the column). If you set it
// to 0.95 then 95% of data will fit into the column width, and the remaining
// 5% will be truncated (" ...").
// Example:
var globalContactDataMinVisiblePercentage=0.95;


