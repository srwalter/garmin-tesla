using Toybox.Application as Application;
using Toybox.System as System;

//! Settings utility.
module Settings {

    //! Store auth token
    function setToken(token) {
        Application.getApp().setProperty(TOKEN, token);
        System.println("Settings: token set to " + token);
    }

    //! Get auth token
    function getToken() {
        var value = Application.getApp().getProperty(TOKEN);
        System.println("Settings: token value is " + value);
        return value;
    }


    // Settings name, see resources/settings/settings.xml
    const TOKEN = "token";
}
