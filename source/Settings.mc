using Toybox.Application as Application;
using Toybox.System as System;

//! Settings utility.
(:background)
module Settings {

    //! Store auth token
    function setToken(token) {
        Application.getApp().setProperty(TOKEN, token);
    }

    //! Get auth token
    function getToken() {
        var value = Application.getApp().getProperty(TOKEN);
        return value;
    }

    // Settings name, see resources/settings/settings.xml
    const TOKEN = "token";
}
