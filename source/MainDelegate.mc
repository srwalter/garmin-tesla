using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.System;
using Toybox.Communications as Communications;
using Toybox.Cryptography;

const OAUTH_CODE = "myOAuthCode";
const OAUTH_ERROR = "myOAuthError";

class MainDelegate extends Ui.BehaviorDelegate {
    var _dummy_mode;
    var _handler;
    var _token;
    var _tesla;
    var _sleep_timer;
    var _vehicle_id;
    var _need_auth;
    var _auth_done;
    var _need_wake;
    var _wake_done;

    var _get_climate;
    var _set_climate;
    var _set_climate_off;
    var _get_charge;
    var _get_vehicle;
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
        _dummy_mode = false;
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

        _set_climate = false;
        _set_climate_off = false;
        _get_climate = true;
        _get_charge = true;
        _get_vehicle = true;
        _honk_horn = false;
        _open_port = false;
        _open_frunk = false;
        _unlock = false;
        _lock = false;

        if(_dummy_mode) {
            _data._vehicle = {
                "vehicle_name" => "Janet"
            };
            _data._charge = {
                "battery_level" => 65,
                "charge_limit_soc" => 80
            };
            _data._climate = {
                "inside_temp" => 25,
                "is_climate_on" => true
            };
        }
        stateMachine();
    }

    function bearerForAccessOnReceive(responseCode, data) {
        if (responseCode == 200) {
            _saveToken(data["access_token"]);
            stateMachine();
        }
        else {
            System.println("Receiving access response: " + responseCode);
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
            System.println("Receiving bearer response: " + responseCode);
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
            System.println("Oauth: Message data is null!");
            _resetToken();
            _handler.invoke(Ui.loadResource(Rez.Strings.label_oauth_error));
        }
    }

    function stateMachine() {
        if(_dummy_mode) {
            _handler.invoke(null);
            return;
        }

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

        if (_get_vehicle) {
            _get_vehicle = false;
            _tesla.getVehicleState(_vehicle_id, method(:onReceiveVehicle));
        }

        if (_get_climate) {
            _get_climate = false;
            _tesla.getClimateState(_vehicle_id, method(:onReceiveClimate));
        }

        if (_get_charge) {
            _get_charge = false;
            _tesla.getChargeState(_vehicle_id, method(:onReceiveCharge));
        }

        if (_set_climate) {
            _set_climate = false;
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
        _get_climate = true;
        _get_charge = true;
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
        if (_data._climate != null && _data._climate.get("is_climate_on")) {
            _set_climate_off = true;
        } else {
            _set_climate = true;
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
        if (_data._vehicle != null && !_data._vehicle.get("locked")) {
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
        _open_frunk = true;
        stateMachine();
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_DOWN);
        return true;
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
        System.println("Got click");
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
            System.println("Auth OK");
            _auth_done = true;
            stateMachine();
        } else {
            System.println("Auth failed: " + responseCode.toString());
            _resetToken();
            _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }

    function onReceiveVehicles(responseCode, data) {
        System.println("on receive vehicles");
        if (responseCode == 200) {
            System.println("Got vehicles");
            var vehicles = data.get("response");
            System.println(vehicles);
            if (vehicles.size() > 0) {
                _vehicle_id = vehicles[0].get("id");
                Application.getApp().setProperty("vehicle", _vehicle_id);
                stateMachine();
            } else {
                _handler.invoke("No vehicles!");
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

    function onReceiveVehicle(responseCode, data) {
        if (responseCode == 200) {
            System.println("Got vehicle");
            _data._vehicle = data.get("response");
            _handler.invoke(null);
        } else {
            if (responseCode == 408) {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            } else {
                if (responseCode == 401) {
                    // Unauthorized
                    _resetToken();
                }
                System.println("error from onReceiveVehicle");
                _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
            }
        }
    }

    function onReceiveClimate(responseCode, data) {
        if (responseCode == 200) {
            _data._climate = data.get("response");
            if (_data._climate.hasKey("inside_temp") && _data._climate.hasKey("is_climate_on")) {
                System.println("Got climate");
                _handler.invoke(null);
            } else {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            }
        } else {
            if (responseCode == 408) {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            } else {
                if (responseCode == 401) {
                    // Unauthorized
                    _resetToken();
                }
                System.println("error from onReceiveClimate");
                _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
            }
        }
    }

    function onReceiveCharge(responseCode, data) {
        if (responseCode == 200) {
            _data._charge = data.get("response");
            if (_data._charge.hasKey("battery_level") && _data._charge.hasKey("charge_limit_soc") && _data._charge.hasKey("charging_state")) {
                System.println("Got charge");
                _handler.invoke(null);
            } else {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            }
        } else {
            if (responseCode == 408) {
                _wake_done = false;
                _sleep_timer.start(method(:delayedWake), 500, false);
            } else {
                if (responseCode == 401) {
                    // Unauthorized
                    _resetToken();
                }
                System.println("error from onReceiveCharge");
                _handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
            }
        }
    }

    function onReceiveAwake(responseCode, data) {
        if (responseCode == 200) {
            _wake_done = true;
            _get_vehicle = true;
            _get_climate = true;
            _get_charge = true;
            stateMachine();
        } else {
            System.println("error from onReceiveAwake - responseCode " + responseCode);
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
            _get_climate = true;
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
            _get_vehicle = true;
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
