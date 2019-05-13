struct App
{
    // App Version (stirng)
    static let APP_VERSION_STRING = "2.0.0"
    
    // App Version (int - for comparison)
    static let APP_VERSION_NUMBER = 200
    
    // App ID from iTunes Conenct
    static let APP_ID = "<APPPLE_APP_ID>"
    
    // NSCoder Archive Name
    static let SPARTAN_ARCHIVE = "spartansArchive"
    
    // Prompt for ad removal after n launches
    static let SETTING_AD_REMOVE_LAUNCHES = 3
    
    // Minimum App Store rating submission
    static let APP_MIN_RATING = 3
    
    // Every n days pull new Halo API content
    static let APP_META_REFRESH_DAYS = 3

    // User Proferences
    struct SettingsKeys {
        static let initialSetupKey = "initialSetup"
        static let hideAdsKey = "hideAds"
        static let numberOfLaunchesKey = "bumberOfLaunches"
        static let lastMetaRefreshKey = "lastMetaRefresh"
        static let numberOfLaunchesForAdRemovalKey = "numberOfLaunchesForAdRemoval"
        static let favoriteSpartansKey = "favoriteSpartans"
    }

    let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
    let currentVeresionRated = UserDefaults.standard.bool(forKey: "currentVeresionRated")

    // Google AdMob
    struct Ads
    {
        // Production Key
        static let ADMOB_UNIT_ID = "<GOOGLE_ADMOB_UNIT_ID>"
        
        // Banner constrint size on screen bottom
        // @todo unhack this
        static let bannerConstraintHeight: CGFloat = 50.0
    }

    // Halo API
    struct HaloApi
    {
        static let BASE_URL = "https://www.haloapi.com/"
        
        // Halo App API Key from https://developer.haloapi.com/
        static let SUBSCRIPTION_KEY = "<HALO_API_KEY>"

        // Storage paths
        static let META_DATA = "/metadata/"
        static let PROFILES = "/profiles/"
    }
}
