using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.System;
using Toybox.Communications as Communications;
using Toybox.Cryptography;

const OAUTH_CODE = "myOAuthCode";
const OAUTH_ERROR = "myOAuthError";

class MainDelegate extends Ui.BehaviorDelegate {
    var _handler;
    var _token;
    var _tesla;
    var _sleep_timer;
    var _vehicle_id;
    var _need_auth;
    var _auth_done;
    var _need_wake;
    var _wake_done;

    var _set_climate_on;
    var _set_climate_off;
    var _get_vehicle_data;
    var _honk_horn;
    var _open_port;
    var _open_frunk;
    var _unlock;
    var _lock;
    var _settings;

    var _data;

    var _code_verifier;

    function initialize(data, handler) {
        BehaviorDelegate.initialize();
        _settings = System.getDeviceSettings();
        _data = data;
        _token = Settings.getToken();
        _vehicle_id = Application.getApp().getProperty("vehicle");
        _sleep_timer = new Timer.Timer();
        _handler = handler;
        _tesla = null;

        if (_token != null && _token.length() != 0) {
            _need_auth = false;
            _auth_done = true;
        } else {
            _need_auth = true;
            _auth_done = false;
        }
        _need_wake = false;
        _wake_done = true;

        _set_climate_on = false;
        _set_climate_off = false;
        _get_vehicle_data = true;
        _honk_horn = false;
        _open_port = false;
        _open_frunk = false;
        _unlock = false;
        _lock = false;

        stateMachine();
    }

    function bearerForAccessOnReceive(responseCode, data) {
        if (responseCode == 200) {
            _saveToken(data["access_token"]);
            stateMachine();
        }
        else {
            _resetToken();
            _handler.invoke(Ui.loadResource(Rez.Strings.label_oauth_error));
        }
    }

    function codeForBearerOnReceive(responseCode, data) {
        if (responseCode == 200) {
            var bearerForAccessUrl = "https://owner-api.teslamotors.com/oauth/token";
            var bearerForAccessParams = {
                "grant_type" => "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "client_id" => "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384",
                "client_secret" => "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"
            };

            var bearerForAccessOptions = {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                   "Authorization" => "Bearer " + data["access_token"]
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };

            Communications.makeWebRequest(bearerForAccessUrl, bearerForAccessParams, bearerForAccessOptions, method(:bearerForAccessOnReceive));
        }
        else {
            _resetToken();
            _handler.invoke(Ui.loadResource(Rez.Strings.label_oauth_error));
        }
    }

    function onOAuthMessage(message) {
        var code = message.data[$.OAUTH_CODE];
        var error = message.data[$.OAUTH_ERROR];
        if (message.data != null) {
            var codeForBearerUrl = "https://auth.tesla.com/oauth2/v3/token";
            var codeForBearerParams = {
                "grant_type" => "authorization_code",
                "client_id" => "ownerapi",
                "code" => code,
                "code_verifier" => _code_verifier,
                "redirect_uri" => "https://auth.tesla.com/void/callback"
            };

            var codeForBearerOptions = {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };

            Communications.makeWebRequest(codeForBearerUrl, codeForBearerParams, codeForBearerOptions, method(:codeForBearerOnReceive));
        } else {
            _resetToken();
            _handler.invoke(Ui.loadResource(Rez.Strings.label_oauth_error));
        }
    }

    function stateMachine() {
        if (_need_auth) {

            _need_auth = false;

            _code_verifier = StringUtil.convertEncodedString(Cryptography.randomBytes(86/2), {
                :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
                :toRepresentation => StringUtil.REPRESENTATION_STRING_HEX,
            });

            var code_verifier_bytes = StringUtil.convertEncodedString(_code_verifier, {
                :fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
                :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            });
            
            var hmac = new Cryptography.HashBasedMessageAuthenticationCode({
                :algorithm => Cryptography.HASH_SHA256,
                :key => code_verifier_bytes
            });

            var code_challenge = StringUtil.convertEncodedString(hmac.digest(), {
                :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
                :toRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
            });

            var params = {
                "client_id" => "ownerapi",
                "code_challenge" => code_challenge,
                "code_challenge_method" => "S256",
                "redirect_uri" => "https://auth.tesla.com/void/callback",
                "response_type" => "code",
                "scope" => "openid email offline_access",
                "state" => "123"                
            };
            
            _handler.invoke(Ui.loadResource(Rez.Strings.label_login_on_phone));

            Communications.registerForOAuthMessages(method(:onOAuthMessage));
            Communications.makeOAuthRequest(
                "https://auth.tesla.com/oauth2/v3/authorize",
                params,
                "https://auth.tesla.com/void/callback",
                Communications.OAUTH_RESULT_TYPE_URL,
                {
                    "code" => $.OAUTH_CODE,
                    "responseError" => $.OAUTH_ERROR
                }
            );
            return;
        }

        if (!_auth_done) {
            return;
        }

        if (_tesla == null) {
            _tesla = new Tesla(_token);
        }

        if (_vehicle_id == null) {
            _handler.invoke(Ui.loadResource(Rez.Strings.label_getting_vehicles));
            _tesla.getVehicleId(method(:onReceiveVehicles));
            return;
        }

        if (_need_wake) {
            _need_wake = false;
            _wake_done = false;
            _handler.invoke(Ui.loadResource(Rez.Strings.label_waking_vehicle));
            _tesla.wakeVehicle(_vehicle_id, method(:onReceiveAwake));
            return;
        }

        if (!_wake_done) {
            return;
        }

        if (_get_vehicle_data) {
            _get_vehicle_data = false;
            _tesla.getVehicleData(_vehicle_id, method(:onReceiveVehicleData));
        }

        if (_set_climate_on) {
            _set_climate_on = false;
            _handler.invoke(Ui.loadResource(Rez.Strings.label_hvac_on));
            _tesla.climateOn(_vehicle_id, method(:onClimateDone));
        }

        if (_set_climate_off) {
            _set_climate_off = false;
            _handler.invoke(Ui.loadResource(Rez.Strings.label_hvac_off));
            _tesla.climateOff(_vehicle_id, method(:onClimateDone));
        }

        if (_honk_horn) {
            _honk_horn = false;
            _handler.invoke(Ui.loadResource(Rez.Strings.label_honk));
            _tesla.honkHorn(_vehicle_id, method(:genericHandler));
        }

        if (_open_port) {
            _open_port = false;
            _handler.invoke(Ui.loadResource(Rez.Strings.label_open_port));
            _tesla.openPort(_vehicle_id, method(:genericHandler));
        }

        if (_unlock) {
            _unlock = false;
            _handler.invoke(Ui.loadResource(Rez.Strings.label_unlock_doors));
            _tesla.doorUnlock(_vehicle_id, method(:onLockDone));
        }

        if (_lock) {
            _lock = false;
            _handler.invoke(Ui.loadResource(Rez.Strings.label_lock_doors));
            _tesla.doorLock(_vehicle_id, method(:onLockDone));
        }

        if (_open_frunk) {
            _open_frunk = false;
            var view = new Ui.Confirmation(Ui.loadResource(Rez.Strings.label_open_frunk));
            var delegate = new SimpleConfirmDelegate(method(:frunkConfirmed));
            Ui.pushView(view, delegate, Ui.SLIDE_UP);
        }
    }

    function frunkConfirmed() {
        _handler.invoke(Ui.loadResource(Rez.Strings.label_frunk));
        _tesla.openFrunk(_vehicle_id, method(:genericHandler));
    }

    function timerRefresh() {
        _get_vehicle_data = true;
        stateMachine();
    }

    function delayedWake() {
        _need_wake = true;
        stateMachine();
    }

    function onSelect() {
        if (_settings.isTouchScreen) {
            return false;
        }

        doSelect();
        return true;
    }

    function doSelect() {
        if (_data._vehicle_data != null && _data._vehicle_data.get("climate_state").get("is_climate_on")) {
            _set_climate_off = true;
        } else {
            _set_climate_on = true;
        }
        stateMachine();
    }

    function onNextPage() {
        if (_settings.isTouchScreen) {
            return false;
        }

        doNextPage();
        return true;
    }

    function doNextPage() {
        if (_data._vehicle_data != null && !_data._vehicle_data.get("vehicle_state").get("locked")) {
            _lock = true;
        } else {
            _unlock = true;
        }
        stateMachine();
    }

    function onPreviousPage() {
        if (_settings.isTouchScreen) {
            return false;
        }

        doPreviousPage();
        return true;
    }

    function doPreviousPage() {
        if (Application.getApp().getProperty("swap_frunk_for_port"))
        {
            _open_port = true;
        }
        else
        {
            _open_frunk = true;
        }
        stateMachine();
    }

    function onBack() {
        return false;
    }

    function onMenu() {
        if (_settings.isTouchScreen) {
            return false;
        }

        doMenu();
        return true;
    }

    function doMenu() {
        if (!_auth_done) {
            return;
        }

        Ui.pushView(new Rez.Menus.OptionMenu(), new OptionMenuDelegate(self), Ui.SLIDE_UP);
    }

    function onTap(click) {
        if (!_data._ready)
        {
            return true;
        }
        
        var coords = click.getCoordinates();
        var x = coords[0];
        var y = coords[1];

        if (x < _settings.screenWidth/2) {
            if (y < _settings.screenHeight/2) {
                doPreviousPage();
            } else {
                doNextPage();
            }
        } else {
            if (y < _settings.screenHeight/2) {
                doSelect();
            } else {
                doMenu();
            }
        }

        return true;
    }

    function onReceiveAuth(responseCode, data) {
        if (responseCode == 200) {
            _auth_done = true;
            stateMachine();
        } else {
            _resetToken();
            _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }

    function onReceiveVehicles(responseCode, data) {
        if (responseCode == 200) {
            var vehicles = data.get("response");
            if (vehicles.size() > 0) {
                _vehicle_id = vehicles[0].get("id");
                Application.getApp().setProperty("vehicle", _vehicle_id);
                stateMachine();
            } else {
                _handler.invoke(Ui.loadResource(Rez.Strings.label_no_vehicles));
            }
        } else {
            if (responseCode == 401) {
                // Unauthorized
                _resetToken();
            }
            _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
            if (responseCode == 408) {
                stateMachine();
            }
        }
    }

    function onReceiveVehicleData(responseCode, data) {
        if (responseCode == 200) {
            _data._vehicle_data = data.get("response");
            if (_data._vehicle_data.get("climate_state").hasKey("inside_temp") && _data._vehicle_data.get("charge_state").hasKey("battery_level")) {
                _handler.invoke(null);
            } else {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            }
        } else if (responseCode != -101) {
            if (responseCode == 408 || responseCode == -5) {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            } else {
                if (responseCode == 401) {
                    // Unauthorized
                    _resetToken();
                }
                _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
            }
        }
    }

    function onReceiveAwake(responseCode, data) {
        if (responseCode == 200) {
            _wake_done = true;
            _get_vehicle_data = true;
            stateMachine();
        } else {
            if (responseCode == 401) {
                // Unauthorized
                _resetToken();
            }
            if (responseCode != -101) {
                _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
            }
            if (responseCode == 408) {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            }
        }
    }

    function onClimateDone(responseCode, data) {
        if (responseCode == 200) {
            _get_vehicle_data = true;
            _handler.invoke(null);
            stateMachine();
        } else {
            if (responseCode == 401) {
                // Unauthorized
                _resetToken();
            }
            _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }

    function onLockDone(responseCode, data) {
        if (responseCode == 200) {
            _get_vehicle_data = true;
            _handler.invoke(null);
            stateMachine();
        } else {
            if (responseCode == 401) {
                // Unauthorized
                _resetToken();
            }
            _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }

    function genericHandler(responseCode, data) {
        if (responseCode == 200) {
            _handler.invoke(null);
            stateMachine();
        } else {
            if (responseCode == 401) {
                // Unauthorized
                _resetToken();
            }
            _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }

    function _saveToken(token) {
        _token = token;
        _auth_done = true;
        Settings.setToken(token);
    }

    function _resetToken() {
        _token = null;
        _auth_done = false;
        Settings.setToken(null);
    }
}