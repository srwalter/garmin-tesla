using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class QuickTesla extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        if (!Sys.getDeviceSettings().phoneConnected) {
            return [ new OfflineView() ];
        }
        return [ new SimpleView(), new SimpleDelegate() ];
    }

}
