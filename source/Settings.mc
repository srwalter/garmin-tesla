using Toybox.Application as Application;
using Toybox.System as System;

//! Settings utility.
(:background)
module Settings {

    //! Store auth token
    function setToken(token) {
        Application.getApp().setProperty(TOKEN, token);
        logMessage("Settings: token set to " + token);
    }

    //! Get auth token
    function getToken() {
        var value = Application.getApp().getProperty(TOKEN);
        logMessage("Settings: token value is " + value);
        return value;
    }

    (:debug)
    function logMessage(message) {
        System.println(message);
    }

    (:release)
    function logMessage(message) {
        
    }

    // Settings name, see resources/settings/settings.xml
    const TOKEN = "token";
}
