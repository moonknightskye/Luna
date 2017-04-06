/*
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: Aug 8, 2015    Updated: Nov 22, 2016
    Native Javascript Utility
    v 2.0.0

    https://success.salesforce.com/answers?id=90630000000glADAAY
*/

(function( $window, $document ) {
    "use strict";
    
    var self = $window.utility;
    
    if ( typeof self === "undefined" ) {
        console.error( "[ ERROR ] utility-sf.js is dependent on utility.js" )
        return;
    };
    
    if ( !self.isUndefined( self.greetUtilitySF ) ) {
        self.log( "utility-sf.js has already been initialized", "ERROR" );
        return;
    }
    
    $window.utility = self.mergeJSON( (function() {
    
        function init() {
            self.log( "initialized utility-sf.js on strict mode." );
            // self.loadResource( _INTERNAL_DATA.connection_api[ "ap1" ], "js", function( dom ){
            //     sforce.connection.sessionId = null;
            //     sforce.connection.debuggingHeader = null; // this, too is necessary!
            //     var user = "mato@demo06.jp";
            //     var pass = "mattaku85";
            //     var token = "1pQSmDdGeIO3ibJFYJx2aRSWW";
            //     var result = sforce.connection.login(user, pass + token);
            //     console.log( result ) 
            //     //Username: mato@demo06.jp
            //     //Security token (case-sensitive): 1pQSmDdGeIO3ibJFYJx2aRSWW
            // });
        };
        
        function greetUtilitySF() {
            self.log( "Hello utility-sf.js" );
        };
        
        function normalizeDate( mydate ) {
           mydate = new Date(mydate );
           mydate = new Date(mydate - mydate.getTimezoneOffset() * 60000);
           return mydate;
        };

        function numberWithCommas( x ) {
            var parts = x.toString().split( "." );
            parts[ 0 ] = parts[ 0 ].replace( /\B(?=(\d{3})+(?!\d))/g, "," );
            return parts.join( "." );
        };

        function querySObject( queryString ) {
            return new Promise( function( resolve, reject ) {
                var callback = {
                    onSuccess: function( result) { 
                        resolve( result.records  );
                    },
                    onFailure: function( a,b ) { 
                        reject( "QUERY FAILED" );
                    },
                    source: {}
                };
                sforce.connection.query( queryString, callback );
            });
        };
        
        function setComponent( param ) {
            _INTERNAL_DATA.component = param; 
        };
        
        function downloadAttachment( fileId ) {
            //https://c.ap2.visual.force.com/servlet/servlet.FileDownload?file=00P2800000HN399EAD
            var arr = $window.location.href.split( "/" );
            var url = arr[ 0 ] + "//" + arr[ 2 ] + "/servlet/servlet.FileDownload?file=" + fileId;
            return url;
        }
        
        function downloadContentFile( LatestPublishedVersionId ) {
            var arr = $window.location.href.split( "/" );
            var url = arr[ 0 ] + "//" + arr[ 2 ] + "/sfc/servlet.shepherd/version/download/" + LatestPublishedVersionId + "?asPdf=false&operationContext=CHATTER";
             if ( self.isRestrictedMode() ) {
                forceNavigateToURL( url );
             } else {
                 //$window
                 return url;
             }
        };
        
        function forceNavigateToURL(  url, isredirect ) {
            if( self.isUndefined( isredirect ) ) {
                isredirect = false;
            }
            executeForceCommand( "navigateToURL", { url: url,  isredirect: isredirect } );
        };
        
        function executeForceCommand( command, params ) {
            $window.$A.get( "e.force:" + command ).setParams( params ).fire();
        };
        
        function executeRemoteAction( controller, command, params ) {
            //   http://stackoverflow.com/questions/20129236/creating-functions-dynamically-in-js
            //   http://stackoverflow.com/questions/5905492/dynamic-function-name-in-javascript
            //
            //   var f = new Function('name, ryan', 'return console.log( name, ryan );');
            //   f( {name: "mato"}, {name: "ryan"} );
            //
            return new Promise( function ( resolve, reject ) {
                
                if( params ) {
                    $window[ controller ][ command ](
                        params,
                        function( result, event ) {
                            if ( event.status ) {
                                resolve( result );
                                self.log( command + " : COMPLETED" );
                            } else if ( event.type === "exception" ) {
                                reject( command +  " :Exception" );
                                self.log( command +  " :Exception", "error" );
                            } else {
                                self.log( command +  " :Unknown Error", "error" );
                            }
                        },
                        { escape: true }
                    );
                } else {
                    $window[ controller ][ command ](
                        function( result, event ) {
                            if ( event.status ) {
                                resolve( result );
                                self.log( command + " : COMPLETED" );
                            } else if ( event.type === "exception" ) {
                                reject( command +  " :Exception" );
                                self.log( command +  " :Exception", "error" );
                            } else {
                                self.log( command +  " :Unknown Error", "error" );
                            }
                        },
                        { escape: true }
                    );
                }
                
            });
        }
        
        function executeAuraCommand( command, params ) {
            if( self.isUndefined( _INTERNAL_DATA.component ) ) {
                self.log( "component not set", "error" );
                return;
            }
            return new Promise( function ( resolve, reject ) {
                var action = _INTERNAL_DATA.component.get( "c." + command );
                if( !self.isUndefined( params ) ) {
                    action.setParams( params );
                }
                action.setCallback( this, function( response ) {
                    var state = response.getState();
                    if (_INTERNAL_DATA.component.isValid() && state === "SUCCESS") {
                        if(response.getReturnValue() !== null) {
                            resolve( response.getReturnValue() );
                        } else {
                            self.log( command + " command returned 0 results" );
                            reject( "empty query" );
                        }
                    } else {
                        self.log( command + " exception occured", "error" );
                        self.log( response.getError() );
                        reject( "exeption" );
                    }
                });
                $window.$A.enqueueAction( action );
            });
        }
        
        function loginAJAXToolkit( uname, pwd, token ) {
            return new Promise( function ( resolve, reject ) {
                return _loadAJAXToolkit( function() {
                    $window.sforce.connection.login( uname, pwd + token );
                    //$window.sforce.connection.init( result.sessionID );
                    self.log( "Successfully logged in AJAX Toolkit" );
                    resolve( "CONNECTED" );
                });
            });
        }
        
        function getSessionID( ) {
            if ( self.isUndefined( $window.sforce ) ) { 
                self.log( "AJAX Toolkit is not available. Try running loadAJAXToolkit( callback ) first.", "ERROR" );
                return false;
            } else if (  self.isUndefined( $window.sforce.connection.sessionId ) ) {
                self.log( "You are not logged in AJAX Toolkit ", "ERROR" );
                return false;
            }
            
            return $window.sforce.connection.sessionId;
        };

        /**
            * BELOW ARE INTERNAL FUNCTIONS USED INSIDE THE LIBRARY
            * THIS SHOULD NOT BE OVERWRITTEN
            */

        var _INTERNAL_DATA = {
            connection_api: {
                local: "../../soap/ajax/37.0/connection.js",
                ap1: "https://ap1.salesforce.com/soap/ajax/37.0/connection.js",
                na1: "https://na1.salesforce.com/soap/ajax/37.0/connection.js",
                cs3: "https://cs3.salesforce.com/soap/ajax/37.0/connection.js"
            },
            component: undefined
        };
        
        function _loadAJAXToolkit( fn ) {
             return new Promise( function ( resolve, reject ) {
                 if ( self.isRestrictedMode() ) {
                    self.log( "AJAX Toolkit is prohibited in Lockerservice.", "ERROR" );
                    reject( "ERROR" );
                     return false;
                }
                
                if ( self.isUndefined( $window.sforce ) ) {
                    self.loadResource( _INTERNAL_DATA.connection_api[ "local" ], "js", function() {
                        if ( !self.isUndefined( fn ) ) {
                             fn();
                        }
                        resolve( "OK" );
                    });
                } else {
                    if ( !self.isUndefined( fn ) ) {
                        fn();
                        resolve( "OK" );
                    }
                }
             });
        };

        
        self.onPageLoad( init );
        
        return{
            downloadAttachment: downloadAttachment,
            executeRemoteAction: executeRemoteAction,
            getSessionID: getSessionID,
            greetUtilitySF: greetUtilitySF,
            loginAJAXToolkit: loginAJAXToolkit,
            querySObject: querySObject,
            normalizeDate: normalizeDate,
            numberWithCommas: numberWithCommas,
            executeAuraCommand: executeAuraCommand,
            setComponent: setComponent,
            executeForceCommand: executeForceCommand,
            forceNavigateToURL: forceNavigateToURL,
            downloadContentFile: downloadContentFile
        };
       })(), self, true );
        
})( typeof window !== "undefined" ? window : this, document );