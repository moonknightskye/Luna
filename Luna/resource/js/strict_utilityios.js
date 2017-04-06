/*
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: Jan 25, 2017    Updated: 
    Native Javascript Utility
    v 1.0.0
*/

(function( $window, $document ) {
    "use strict";
    
    var self = $window.utility;
    
    if ( typeof self === "undefined" ) {
        console.error( "[ ERROR ] utility-ios.js is dependent on utility.js" );
        return;
    }

    if ( typeof webkit === "undefined" ) {
        console.error( "[ ERROR ] utility-ios.js can only be used inside an iOS application" );
        return;
    }
    
    if ( !self.isUndefined( self.greetUtilityIOS ) ) {
        self.log( "utility-ios.js has already been initialized", "ERROR" );
        return;
    }
    
    $window.utility = self.mergeJSON( (function() {
    
        function init() {
            self.log( "initialized utility-ios.js on strict mode." );
        };

        function runJSCommand( cmd ) {
            (function( _cmd ) {
                if( $window.utility[ _cmd.command ].constructor === Function  ) {
                    $window.utility[ _cmd.command ]( _cmd.params );
                }
            })( JSON.parse( cmd ) );
        };

        function oniOSLoad( fn ) {
            if( _INTERNAL_DATA.isiOSReady ) {
                $window.setTimeout( fn );
            } else {
                _INTERNAL_DATA.initiOSFns.push( fn );
            }
        };

        function oniOSMotion( fn, interval ) {
            _INTERNAL_DATA.motion_id += 1;
            interval = ( interval || 0 ) / 1000;
            _INTERNAL_DATA.iosmotionFns.push( {
                motion_id: _INTERNAL_DATA.motion_id,
                interval: interval,
                fn: fn
            });
            runSwiftCommand( "self", "startDeviceMotionUpdates", { motion_id: _INTERNAL_DATA.motion_id, interval: interval } );

            return _INTERNAL_DATA.motion_id;
        };

        function onPedometerUpdate( fn ) {
            _INTERNAL_DATA.pedometer_id += 1;
            _INTERNAL_DATA.pedometerFns.push( {
                pedometer_id: _INTERNAL_DATA.pedometer_id,
                fn: fn
            });
            runSwiftCommand( "self", "startPedometerUpdates", { pedometer_id: _INTERNAL_DATA.pedometer_id } );

            return _INTERNAL_DATA.pedometer_id;
        };

        function runPedometerUpdate( pedometer_id, result ) {
            var pedometerfn = self.forEvery( _INTERNAL_DATA.pedometerFns, function( _pedometerfn ) {
                if( _pedometerfn.pedometer_id === parseInt(pedometer_id) ) { return _pedometerfn; }
            });
            if( pedometerfn ) {
                (function( _result ) {
                    pedometerfn.fn( _result );
                })( JSON.parse( result ) )
            }
        };

        function clearPedometerUpdate( pedometer_id ) {
            self.forEvery( _INTERNAL_DATA.pedometerFns, function( pedometerfn, index ) {
                if( pedometerfn.pedometer_id === pedometer_id ) {
                    _INTERNAL_DATA.pedometerFns.splice( index, 1 );
                }
            });
            return runSwiftCommand( "self", "stopPedometerUpdates", { pedometer_id: pedometer_id } );
        };

        function cleariOSMotion( motion_id ) {
            self.forEvery( _INTERNAL_DATA.iosmotionFns, function( iosmotionfn, index ) {
                if( iosmotionfn.motion_id === motion_id ) {
                    _INTERNAL_DATA.iosmotionFns.splice( index, 1 );
                }
            });
            return runSwiftCommand( "self", "stopDeviceMotionUpdates", { motion_id: motion_id } );
        };

        function runiOSMotion( motion_id, result ) {
            var iosmotion = self.forEvery( _INTERNAL_DATA.iosmotionFns, function( _iosmotion ) {
                if( _iosmotion.motion_id === parseInt(motion_id) ) { return _iosmotion; }
            });
            if( iosmotion ){
                (function( _result ) {
                    iosmotion.fn( _result );
                })( JSON.parse( result ) )
            }
        };

        function runSwiftDownloader( param ) {

        };


        function initWebView( param ) {
            if( !self.isUndefined( _INTERNAL_DATA.webview_id ) || self.isUndefined( param ) )  { return; };

            _INTERNAL_DATA.webview_id = parseInt( param );

            //utility.getElement("mato","id").innerText = parseInt( param );
            _INTERNAL_DATA.isiOSReady = true;
            self.forEvery( _INTERNAL_DATA.initiOSFns, function( initiosfn ) {
                initiosfn();
            });
            delete _INTERNAL_DATA.initiOSFns;
        };

        function base64ToPNG( base64 ) {
            return "data:image/png;base64," + base64;
        };

        function runOnLoadWebView( command_id, webview_id ) {
            self.forEvery( _INTERNAL_DATA.webviewOnLoadFns, function( webviewonload, index ) {
                if( webviewonload.command_id === parseInt(command_id) ) {
                    (function(_webview_id){
                        webviewonload.onLoad( _webview_id );
                    })( webview_id );
                    _INTERNAL_DATA.webviewOnLoadFns.splice(index, 1);
                }
            });
        };

        function runOnLoadedWebView( command_id, webview_id ) {
            self.forEvery( _INTERNAL_DATA.webviewOnLoadedFns, function( webviewonloaded, index ) {
                if( webviewonloaded.command_id === parseInt(command_id) ) {
                    (function(_webview_id){
                        webviewonloaded.onLoaded( _webview_id );
                    })( webview_id );
                    _INTERNAL_DATA.webviewOnLoadedFns.splice(index, 1);
                }
            });
        };

        function greetUtilityIOS(){};

        function runSwiftCommand( target_webview_id, command, params ) {
            if( target_webview_id.toString().toUpperCase() === "SELF" ) {
                target_webview_id = getWebViewID();
            }
            if( self.isUndefined( params ) ) {
                params = {};
            }

            return new Promise( function ( resolve, reject ) {
                _addSwiftCommand( target_webview_id, command, params, function( result ){
                    if( result.status === 1) {
                        resolve( result );
                    } else if( result.status === 0) {
                        reject( result );
                    }
                })
            });
        };

        function resolveSwiftCommand( params ) {
            var ioscommand = self.forEvery( _INTERNAL_DATA.ioscommands, function( _ioscommand ) {
                if( _ioscommand.command_id === parseInt( params.command_id ) ) {
                    return _ioscommand;
                }
            });
            if( ioscommand ) {
                if( ioscommand.onSuccess ) {
                    ioscommand.onSuccess( params );
                }
            }
        };

        // function resolveSwiftCommand( command_id, params ) {
        //     var ioscommand = self.forEvery( _INTERNAL_DATA.ioscommands, function( _ioscommand ) {
        //         if( _ioscommand.command_id === parseInt( command_id ) ) {
        //             return _ioscommand;
        //         }
        //     });
        //     if( ioscommand ) {
        //         if( ioscommand.onSuccess ) {
        //             (function(result){
        //                 ioscommand.onSuccess( result );
        //             })( JSON.parse( params ) );
        //         }
        //     }
        // };



        function getWebViewID() {
            return _INTERNAL_DATA.webview_id;
        };


        function sendToApp( func_name, message ) {
            webkit.messageHandlers[ func_name ].postMessage( message );
        };

        function debugiOS( data ) {
            if( data.constructor === Object ) {
                data = JSON.stringify( data )
            }
            self.appendJSONDOM({
                tag:"DIV",
                text: data
            });
        };

        /**
            * BELOW ARE INTERNAL FUNCTIONS USED INSIDE THE LIBRARY
            * THIS SHOULD NOT BE OVERWRITTEN
            */

        var _INTERNAL_DATA = {
            webview_id: undefined,
            command_id: 0,
            ioscommands: [],
            initiOSFns: [],
            iosmotionFns: [],
            webviewOnLoadFns: [],
            webviewOnLoadedFns: [],
            fileDLProgressFns:[],
            motion_id: 0,
            pedometer_id: 0,
            pedometerFns:[],
            isiOSReady: false
        };

        function _addSwiftCommand( target_webview_id, command, params, fn ) {
            _INTERNAL_DATA.command_id += 1;

            _INTERNAL_DATA.ioscommands.push({
                command_id: _INTERNAL_DATA.command_id,
                source_webview_id: _INTERNAL_DATA.webview_id,
                target_webview_id: target_webview_id,
                command: command,
                params: params,
                status: -1,
                onSuccess: fn
            });

            _proccessSwiftCommand( _INTERNAL_DATA.command_id, command, params );
            //_serializeJSONDate( params );

            sendToApp("webcommand",
                JSON.stringify( {
                    command: command,
                    command_id: _INTERNAL_DATA.command_id,
                    source_webview_id: _INTERNAL_DATA.webview_id,
                    target_webview_id: target_webview_id,
                    params: params
                })
            );
        };

        function _proccessSwiftCommand( command_id, command, params ) {
            switch( command ) {
                case "newWebView":
                    if( !self.isUndefined( params.onLoad ) ) {
                        _INTERNAL_DATA.webviewOnLoadFns.push({
                            command_id: command_id,
                            onLoad: params.onLoad
                        });
                        params.onLoad = true;
                    }
                    if( !self.isUndefined( params.onLoaded ) ) {
                        _INTERNAL_DATA.webviewOnLoadedFns.push({
                            command_id: command_id,
                            onLoaded: params.onLoaded
                        });
                        params.onLoaded = true;
                    }
                    
                    break;
                case "downloadFile2":
                    if( !self.isUndefined( params.onProgress ) ) {
                        _INTERNAL_DATA.fileDLProgressFns.push({
                            command_id: command_id,
                            onProgress: params.onProgress
                        });
                        params.onProgress = true;
                    }
                    break;
            };
        };

        function _serializeJSONDate( json ) {
            self.forEveryKey( json, function( value, key ) {
                if( value.constructor === Object ) {
                    _serializeJSONDate( value );
                } else if( value.constructor === Date ) {
                    _serializeDate( value )
                }
            });
        };

        function _serializeDate( date ) {
            date.setHours( date.getHours() - date.getTimezoneOffset() / 60 );
        };
        
        self.onPageLoad( init );
        
        return {
            base64ToPNG: base64ToPNG,
            cleariOSMotion: cleariOSMotion,
            clearPedometerUpdate: clearPedometerUpdate,
            initWebView: initWebView,
            getWebViewID: getWebViewID,
            greetUtilityIOS: greetUtilityIOS,
            oniOSLoad: oniOSLoad,
            oniOSMotion: oniOSMotion,
            onPedometerUpdate: onPedometerUpdate,
            sendToApp: sendToApp,
            runJSCommand: runJSCommand,
            runSwiftCommand: runSwiftCommand,
            runSwiftDownloader: runSwiftDownloader,
            resolveSwiftCommand: resolveSwiftCommand,
            runiOSMotion: runiOSMotion,
            runPedometerUpdate: runPedometerUpdate,
            runOnLoadWebView: runOnLoadWebView,
            runOnLoadedWebView: runOnLoadedWebView
        };
       })(), self, true );
        
})( typeof window !== "undefined" ? window : this, document );