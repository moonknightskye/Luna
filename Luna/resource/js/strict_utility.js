/**
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: Aug 8, 2015    Updated: Dec 20, 2016
    Native Javascript Utility
    v 2.1.0

    salesforce connection api
    https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_connecting.htm

      SfdcApp.Visualforce.viewstate.ViewstateSender.sendViewstate('https://ap2.salesforce.com', 'DEM_TireQuote');    
**/

(function( $window, $document ) {
    "use strict";
    
    if ( typeof $window.utility !== "undefined" ) {
        $window.utility.log( "utility.js has already been initialized", "ERROR" );
        return false;
    }

    $window.utility = (function() {
        function init( fn ) {
            if ( _INTERNAL_DATA.isInit ) {
                return;
            }
            _INTERNAL_DATA.isInit = true;
            if ( fn ) {
                fn();
            }
            forEvery( _INTERNAL_DATA.initFns, function( initfn ) {
                initfn();
            });
            delete _INTERNAL_DATA.initFns;
        };
        
        function onPageLoad( fn ) {
            if ( $document.readyState === "complete" || 
               ( $document.readyState !== "loading" && !$document.documentElement.doScroll ) ) {
                if ( !_INTERNAL_DATA.isInit ) {
                    _loadCompleted();
                }
                $window.setTimeout( fn );
            } else {
                _INTERNAL_DATA.initFns.push( fn );
            }
        };
        
        function onWindowResize( fn ) {
            _INTERNAL_DATA.winResizeFns.push( fn );
        };
        
        function windowResize( fn ) {
            $window.clearTimeout( _INTERNAL_DATA.winResizeTimer );
            _INTERNAL_DATA.winResizeTimer = $window.setTimeout(function() {
                var _width = getPageDimentions().width;
                if ( _INTERNAL_DATA.winResizeWidth === _width ) {
                    return true;
                } else {
                    _INTERNAL_DATA.winResizeWidth = _width;
                }
                if ( fn ) {
                    fn();
                }
                forEvery( _INTERNAL_DATA.winResizeFns, function( winresfn ) {
                    winresfn();
                });
            }, _INTERNAL_DATA.winResizeTimeout );
        };
        
        function onOrientationChange( fn ) {
            _INTERNAL_DATA.orientFns.push( fn );
        };
        
        function orientationChange( fn ) {
            var orientation = getPageOrientation();
            if ( fn ) {
                fn( orientation );
            }
            forEvery( _INTERNAL_DATA.orientFns, function( orntfn ) {
                orntfn( orientation );
            });
        };
        
        function getPageOrientation() {
            //more info here: https://davidwalsh.name/orientation-change
            switch ( ( screen.orientation ) ? screen.orientation.angle: window.orientation ) {
                case -90:
                case 90:
                    return "landscape"; break;
                default:
                    return "portrait"; break;
             }
        };
        
        function getElement( param, type, loc ) {
            type = ( type || "CLASS" ).toUpperCase();
            loc = loc || $document;
            switch ( type ) {
                default:
                case "CLASS":
                    return loc.getElementsByClassName( param );
                    break;
                case "ID":
                    return loc.getElementById( param );
                    break;
                case "TAG":
                    return loc.getElementsByTagName( param );
                    break;
                case "DATA":
                    if( param.constructor === String ) {
                        return loc.querySelectorAll( "[data-" + param + "]" );
                    } else if ( param.constructor === Object ) {
                        var _str = "";
                        forEveryKey( param, function( value, key ){
                            _str += "[data-" + key + "='"+ value +"']";
                        });
                        if( _str.length > 0 ) {
                            return loc.querySelectorAll( _str );
                        }
                    }
                    break;
                case "SELECT":
                    return loc.querySelector( param );
                    break;
                case "ALL":
                    return loc.querySelectorAll( param );
                    break;
            }
        };
        
        function getParent( elem, fn ) {
            var _return;
            var parent = elem.parentElement;
            if ( parent.nodeName === "BODY" ) {
                return false;
            }
            if ( isUndefined( fn ) ) {
               return parent; 
            }
            ( function( _parent ) {
                _return = fn( _parent );
            })( parent );
            if ( !isUndefined( _return ) ) return _return;
    
            return getParent( parent, fn );
        };

        function forEvery( param, fn ) {
            if ( isUndefined( param ) || isUndefined( fn ) ) {
                return;
            }
            if ( param.constructor === Object ) {
                param = [ param ];
            }  else if ( param.constructor === Number ) {
                var _param = [];
                for( var j = 1; j <= param; j++ ) {
                    _param.push( j );
                }
                param = _param;
            } else if ( param.constructor !== Array ) {
                param = Array.prototype.slice.call( param, 0 );
            }
            var _return;
            param.some(function( val,  i ) {
                _return = fn( val, i );
                if ( !isUndefined( _return ) ) {
                    return true;
                }
            });
            return _return || false;
        };
        
        function forEveryKey( param, fn ) {
            if ( isUndefined( param ) || isUndefined( fn ) ) {
                return;
            }
            var _return;
            forEvery( Object.keys( param ), function( val ) {
                _return = fn( param[ val ], val );
                if ( !isUndefined( _return ) ) {
                    return true;
                }
            });
            return _return || false;
        };
        
        function getPrefix() {
            return _INTERNAL_DATA.prefix = _INTERNAL_DATA.prefix || (function () {
                var styles = $window.getComputedStyle( $document.documentElement, "" ),
                    matches,
                    pre = ( styles.OLink === "" && ["", "o"]) || forEveryKey( styles, function( value, key ) {
                        if ( key ) {
                            matches = key.match( /^(moz|webkit|ms)/ );
                            if ( matches && matches.length > 0 ) {
                                return  matches[0];
                            }
                        }
                    } ),
                    dom = ( "WebKit|Moz|MS|O" ).match( new RegExp( "(" + pre + ")", "i" ) )[ 1 ];
                return {
                    dom: dom,
                    lowercase: pre,
                    css: "-" + pre + "-",
                    js: pre[ 0 ].toUpperCase() + pre.substr( 1 )
                  };
            })();
        };

        function setJSONtoDOM( DOM, datasetName ) {
            if( isUndefined(datasetName) ) {
                datasetName = "json"
            }
            console.log(DOM)
            console.log( datasetName )
            forEveryKey( DOM, function(value, key){
                console.log({datasetName:key})
                console.log( getElement( {datasetName:key}, "DATA" ) )
                forEvery( getElement( {datasetName:key}, "DATA" ), function( element ) {
                    console.log(element)
                    switch( element.nodeName ) {
                        case "DIV":
                            element.innerText = value;
                            break;
                        default:
                            log( element.nodeName + " is not supported" );
                    }
                    
                })
            })
        };

        function isUndefined( param ) {
            return ( typeof param === "undefined" );
        };

        function allowPageScrolling( isAllow ) {
            if ( isUndefined( isAllow ) ) isAllow = true;
            
            forEvery ( _getScrollEvents(), function( scrollevt ) {
                if ( !isAllow ) {
                    $window.addEventListener( scrollevt, _preventDefault, false );
                } else {
                    $window.removeEventListener( scrollevt, _preventDefault, false );
                }
            } );
            if ( !isAllow ) {
                $document.addEventListener( "touchmove", _preventDefault, false );
                $document.addEventListener( "mousewheel", _preventDefault, false );
                $document.addEventListener( "keydown", _preventDefaultForScrollKeys, false );
            } else {
                $document.removeEventListener( "touchmove", _preventDefault, false );
                $document.removeEventListener( "mousewheel", _preventDefault, false );
                $document.removeEventListener( "keydown", _preventDefaultForScrollKeys, false );
            }
            log( "Page scrolling is " + ( ( isAllow ) ? "enabled" : "disabled" ) );
            return isAllow;
        };
        
        function allowLogging( isAllow ) {
            if( isUndefined(isAllow) ){
                isAllow = true;
            }
            _INTERNAL_DATA.showLogs = isAllow;
            log( "utility: logging is " + ( ( _INTERNAL_DATA.showLogs ) ? "enabled" : "disabled" ) );
        };

        // function base64ToImage( base64, fn ) {
        //     var decoded = decode64( base64 );
        //     var extension = undefined;
        //     // do something like this
        //     var lowerCase = decoded.toLowerCase();
        //     if (lowerCase.indexOf("png") !== -1){
        //         extension = "png";
        //     } else if (lowerCase.indexOf("jpg") !== -1 || lowerCase.indexOf("jpeg") !== -1) {
        //         extension = "jpg";
        //     } else {
        //         extension = "tiff";
        //     }
            
        //     return "data:image/" + extension + ";base64," + base64;
        // };
        
        function log( message, type ) {
            if ( _INTERNAL_DATA.showLogs ) {
                type = ( type || "INFO" ).toUpperCase();
                switch( type ) {
                    default:
                    case "INFO":
                        console.info( "[ INFO ] " + message ); break;
                    case "TRACE":
                        console.trace( "[ TRACE ] " + message ); break;
                    case "WARN":
                        console.warn( "[ WARN ] " + message ); break;
                    case "ERROR":
                        console.error( "[ ERROR ] " + message ); break;
                    case "BUG":
                        console.error( "[ BUG ] " + message ); break;
                }
            }
        };
        
        function getURLParameter( name ) {
            name = name.replace( /[\[]/ , "\\\[" ).replace( /[\]]/ , "\\\]" );
            var regex = new RegExp( "[\\?&]" + name + "=([^&#]*)" );
            var results = regex.exec( location.href );
            return results == null ? null : results[ 1 ];
        };
        
        function randomize( min, max ) {
             if ( isUndefined( max ) ) {
                 max = min;
                 min = 1;
             }
            return Math.floor( Math.random() * ( max - min + 1 ) + min );
        };
        
        function scrollTo( element, param, fn ) {
            // more info here: https://coderwall.com/p/hujlhg/smooth-scrolling-without-jquery
            // http://stackoverflow.com/questions/4801655/how-to-go-to-a-specific-element-on-page
            element = element || $document.body;
            var promise;
            if ( !isUndefined( param.top ) ) {
                promise = smoothStep( element[ "scrollTop" ], param.top, param.duration || 400, function( value, percent ) {
                    element[ "scrollTop" ] = value;
                });
            }
            if ( !isUndefined( param.left ) ) {
                promise = smoothStep( element[ "scrollLeft" ], param.left, param.duration || 400, function( value, percent ) {
                    element[ "scrollLeft" ] = value;
                });
            }
            if ( fn ) {
                promise.then( fn )
            }
        };
        
        function loadResource( filename, filetype, fn ) {
            var fileref;
            filetype = ( filetype || filename.substring( filename.lastIndexOf( "." ) + 1, filename.length ) ).toLowerCase();
    
            var resource = _isResourceExists( filename, filetype );
            if ( resource ) {
                log( filename + " already exists" , "ERROR" );
            } else {
                if ( filetype === "js" ) {
                    fileref = $document.createElement( "script" );
                    fileref.setAttribute( "type", "text/javascript" );
                    fileref.setAttribute( "src" , filename );
                } else if ( filetype === "css" ) {
                    fileref = $document.createElement( "link" );
                    fileref.setAttribute( "rel", "stylesheet" );
                    fileref.setAttribute( "type", "text/css" );
                    fileref.setAttribute( "href", filename );
                }
                fileref.setAttribute( "async", "" );
                //add the resources to the body of the document instead of the head
                //getElement( "head", "TAG" )[ 0 ].appendChild( fileref );
                $document.body.appendChild( fileref );
                if ( !isUndefined( fn ) ) {
                    addOneTimeEventListener( fileref, "load", function() {
                        fn( fileref );
                    });
                }
            }
        };
        
        function unloadResource( filename, filetype, fn ) {
            filetype = ( filetype || filename.substring( filename.lastIndexOf( "." ) + 1, filename.length ) ).toLowerCase();
            var resource = _isResourceExists( filename, filetype );
            if ( resource ) {
                removeDOM( resource, fn );
            } else {
                log( filename + " does not exists.", "ERROR" );
            }
        };
        
        function mergeJSON( obj1, obj2, isBackupDuplicate ) {
            var obj3 = {};
            forEveryKey( obj2, function( value, key ) {
                obj3[ key ] = value;
            });
            forEveryKey( obj1, function( value, key ) {
                if ( isBackupDuplicate ) {
                    if ( obj3.hasOwnProperty( key ) ) {
                        obj3[ key + "__super" ] = obj3[ key ];
                    }
                }
                obj3[ key ] = value;
            });
            return obj3;
        };
        
        //https://cdnjs.com <--- hosting libararies
        //https://www.google.com/fonts#
        function loadGoogleFonts( family, element, fn ) {
            var encode_family = family.replace( " ", "+" ).replace( ",", "|" );
            $window.WebFontConfig = {
                google: { families: [ encode_family || _INTERNAL_DATA.googleFontDefault ] }
            };
            loadResource( _INTERNAL_DATA.googleFontURL, "js", function( DOM ) {
                forEvery( getElement( "*", "TAG", element || $document.body ), function( el ) {
                    el.style.fontFamily = family;
                });
                if ( !isUndefined( fn ) ) {
                    fn( DOM, family );
                }
            });
        };
        
        function prependDOM( child, parent, fn ) {
            parent = parent || getParent( child );

            if ( !parent.firstChild ) {
                appendDOM( child, parent, fn )
                return;   
            }
            addOneTimeEventListener( parent, "DOMNodeInserted", fn );
            parent.insertBefore( child, parent.firstChild );
        };
        
        function appendDOM( child, parent, fn ) {
            parent = parent || getParent( child );
            //addOneTimeEventListener( parent, "DOMNodeInserted", fn );
            
            /*
             * http://salesforce.stackexchange.com/questions/146370/cannot-use-select2-jquery-library-in-lightning-components-with-lorckerservice-ac/146380
             */
            var observer = new MutationObserver( function( mutations ) {
              mutations.forEach( function( mutation ) {
                if ( mutation.type === "childList" ) {
                    if ( fn ) {
                        fn();
                    }
                }
              });    
            });
            observer.observe( parent, { attributes: true, childList: true, characterData: true } );
           
            //log( "problem with MutationObserver... this wont work in firefox: TO BE SUPPORTED THIS 11-11-2017" );
            //log( "http://salesforce.stackexchange.com/questions/146370/cannot-use-select2-jquery-library-in-lightning-components-with-lorckerservice-ac/146380" )
            parent.appendChild( child );
        };
        
        function removeDOM( child, parent, fn ) {
            parent = parent || getParent( child );
            addOneTimeEventListener( parent, "DOMNodeRemoved", fn );
            parent.removeChild( child );
        };
        
        
        //TODO: removeEventListener is not available in arai
        function addOneTimeEventListener( elem, event, fn ) {
            if ( isUndefined( event ) || isUndefined( fn ) ) {
                return;
            }
            
            var _callback = function() {
                if ( elem.removeEventListener ) {
                    elem.removeEventListener( event, _callback );
                } else {
                    log("element cannot handle removeEventListener: " + event, "BUG");
                }
                fn();
            }
            elem.addEventListener( event, _callback );
        };
        
        var getPageDimentions = function() {
            if( isRestrictedMode() ) {
                var msg = "Returned Height value is inaccurate. " +
                "Check link for details: " +
                "http://salesforce.stackexchange.com/questions/127300/window-access-on-secure-dom-lockerservice" 
                //log( msg, "BUG" );
            };
            return {
                width: (function() {
                  if ( $window.innerWidth ) {
                    return $window.innerWidth;
                  }
                  if ( $document.documentElement && $document.documentElement.clientWidth ) {
                    return $document.documentElement.clientWidth;
                  }
                  if ( $document.body ) {
                    return $document.body.clientWidth;
                  }
                })(),
                height: (function() {
                  if ( $window.innerHeight ) {
                    return $window.innerHeight;
                  }
                  if ( $document.documentElement && $document.documentElement.clientHeight ) {
                    return $document.documentElement.clientHeight;
                  }
                  if ( $document.body ) {
                    return $document.body.clientHeight;
                  }
                })()
            }  
        };
       
        function isTouchDevice() {
            return ( ( "ontouchstart" in $window )
                    || ( navigator.MaxTouchPoints > 0 )
                    || ( navigator.msMaxTouchPoints > 0 ) );
        };
        
        function isRestrictedMode() {
            return !isUndefined( $window.$A );
        }
        
        function extendSuperFunction() {
            log("THIS IS THE ORIGINAL extendSuperFunction");
        };
        
        function commaSeparateNumber( param ) {
            return param.toString().replace( /\B(?=(\d{3})+(?!\d))/g, "," );
        };
        
        function getBrowser() {
            if((navigator.userAgent.indexOf("Opera") || navigator.userAgent.indexOf('OPR')) != -1 ) {
                return "Opera";
            } else if(navigator.userAgent.indexOf("Chrome") != -1 ) {
                return "Chrome";
            } else if(navigator.userAgent.indexOf("Safari") != -1) {
                return "Safari";
            } else if(navigator.userAgent.indexOf("Firefox") != -1 ) {
                return "Firefox";
            } else if((navigator.userAgent.indexOf("MSIE") != -1 ) || (!!document.documentMode == true )) {
                return "MSIE"; 
            } else {
               return "unknown";
            }
        };
        
        function splice( parent, child, compareKey ) {
            var pos = - 1;
            forEvery(parent, function(_child, i) {
                if( compareKey ) {
                    if( child.hasOwnProperty(compareKey) &&  _child.hasOwnProperty(compareKey) ) {
                        if( child[ compareKey ] === _child[ compareKey ] ) {
                            pos = i;
                            return false;
                        }
                    }
                } else {
                    if( _child === child ) {
                        pos = i;
                        return false;
                    }
                }
            });
            if( pos > -1 ) {
                return parent.splice(pos, 1);
            }
        };

        function smoothStep ( current, target, duration, fn ) {
            target = Math.round( target );
            duration = Math.round( duration );
            if ( duration < 0 ) {
                return Promise.reject( "bad duration" );
            }
            if ( duration === 0 ) {
                current = target;
                return Promise.resolve();
            }
            var start_time = Date.now();
            var end_time = start_time + duration;
            var start_top = current;
            var distance = target - start_top;
      
            // based on http://en.wikipedia.org/wiki/Smoothstep
            var smooth_step = function ( start, end, point ) {
                if ( point <= start ) { return 0; }
                if ( point >= end ) { return 1; }
                var x = ( point - start ) / ( end - start );
                return x * x * ( 3 - 2 * x );
            };
      
            return new Promise (function( resolve, reject ) {
                var previous_top = current;
                var scroll_frame = function() {
                    if ( current != previous_top ) {
                        reject( "interrupted smoothStep" );
                        return;
                    }
                    var now = Date.now();
                    var point = smooth_step( start_time, end_time, now );
                    var frameTop = Math.round( start_top + ( distance * point ) );
                    current = frameTop;
                    if ( now >= end_time ) {
                        resolve( "finished smoothStep" );
                        return;
                    }
                    if ( current === previous_top && current !== frameTop ) {
                        resolve();
                        return;
                    }
                    previous_top = current;

                    ( function( _countNow, _percentage ) {
                        fn( _countNow, _percentage );
                    })( previous_top, Math.round( point * 100 ) );

                    setTimeout( scroll_frame, 0 );
                };
                setTimeout( scroll_frame, 0 );
            });
        };
        
        function isMobile() {
            if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                return true;
            }
            return false;
        };
        
        function getDate( date, addDay ) {
            date = date || new Date();
            if ( !addDay ){
                return date;
            } 
            date.setDate( date.getDate() + addDay );
            return date;
        };

        function setCookie( name, value, expires, domain, path, secure ) {
            var buffer = name + "=" + $window.encodeURIComponent( value );
            if ( !isUndefined(expires) ) {
                buffer += "; expires=" + new Date( expires ).toUTCString();
            }
            if ( !isUndefined(domain) ) {
                buffer += "; domain=" + domain;
            }
            if ( !isUndefined(path) ) {
                buffer += "; path=" + path;
            }
            if ( secure ) {
                buffer += '; secure';
            }
            $document.cookie = buffer;
        };

        function getCookie( name ) {
            var match = ( "; " + $document.cookie + ";" ).match( "; " + name + "=(.*?);" );
            return match ? $window.decodeURIComponent( match[ 1 ] ) : "";
        };

        function utf8ToBase64( utf8 ) {
            return $window.btoa( $window.unescape( $window.encodeURIComponent( utf8 ) ) );
        };

        function base64ToUTF8( base64 ) {
            return $window.decodeURIComponent( $window.escape( $window.atob( base64 ) ) );
        };

        function base64ToBlob( base64, contentType, sliceSize ) {
            contentType = contentType || "";
            sliceSize = sliceSize || 512;
            var byteCharacters = $window.atob( base64 );
            var byteArrays = [];
            for ( var offset = 0; offset < byteCharacters.length; offset += sliceSize ) {
                var slice = byteCharacters.slice( offset, offset + sliceSize );
                var byteNumbers = new Array( slice.length );
                for ( var i = 0; i < slice.length; i++ ) {
                    byteNumbers[ i ] = slice.charCodeAt( i );
                }
                var byteArray = new Uint8Array( byteNumbers );
                byteArrays.push(byteArray);
            }
            return new Blob( byteArrays, { type: contentType } );
        };

        function base64ToObjectURL( base64, contentType ) {
            return $window.URL.createObjectURL( base64ToBlob( base64, contentType ) );
        };

        // function encode64(input) {
        //     input = escape(input);
        //     var output = "";
        //     var chr1, chr2, chr3 = "";
        //     var enc1, enc2, enc3, enc4 = "";
        //     var i = 0;

        //     do {
        //         chr1 = input.charCodeAt(i++);
        //         chr2 = input.charCodeAt(i++);
        //         chr3 = input.charCodeAt(i++);

        //         enc1 = chr1 >> 2;
        //         enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        //         enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        //         enc4 = chr3 & 63;

        //         if (isNaN(chr2)) {
        //             enc3 = enc4 = 64;
        //         } else if (isNaN(chr3)) {
        //            enc4 = 64;
        //         }

        //         output = output +
        //            _INTERNAL_DATA.keyStr.charAt(enc1) +
        //            _INTERNAL_DATA.keyStr.charAt(enc2) +
        //            _INTERNAL_DATA.keyStr.charAt(enc3) +
        //            _INTERNAL_DATA.keyStr.charAt(enc4);
        //         chr1 = chr2 = chr3 = "";
        //         enc1 = enc2 = enc3 = enc4 = "";
        //      } while (i < input.length);

        //      return output;
        // };

        // function decode64( input ) {
        //     var output = "";
        //     var chr1, chr2, chr3 = "";
        //     var enc1, enc2, enc3, enc4 = "";
        //     var i = 0;

        //      // remove all characters that are not A-Z, a-z, 0-9, +, /, or =
        //     var base64test = /[^A-Za-z0-9\+\/\=]/g;
        //     if (base64test.exec(input)) {
        //         alert("There were invalid base64 characters in the input text.\n" +
        //               "Valid base64 characters are A-Z, a-z, 0-9, '+', '/',and '='\n" +
        //               "Expect errors in decoding.");
        //     }
        //     input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

        //     do {
        //         enc1 = _INTERNAL_DATA.keyStr.indexOf(input.charAt(i++));
        //         enc2 = _INTERNAL_DATA.keyStr.indexOf(input.charAt(i++));
        //         enc3 = _INTERNAL_DATA.keyStr.indexOf(input.charAt(i++));
        //         enc4 = _INTERNAL_DATA.keyStr.indexOf(input.charAt(i++));

        //         chr1 = (enc1 << 2) | (enc2 >> 4);
        //         chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        //         chr3 = ((enc3 & 3) << 6) | enc4;

        //         output = output + String.fromCharCode(chr1);

        //         if (enc3 != 64) {
        //            output = output + String.fromCharCode(chr2);
        //         }
        //         if (enc4 != 64) {
        //            output = output + String.fromCharCode(chr3);
        //         }

        //         chr1 = chr2 = chr3 = "";
        //         enc1 = enc2 = enc3 = enc4 = "";

        //     } while (i < input.length);

        //     return unescape(output);
        // };
        
        
        
        
        
        
        
        
        
        /**
            * BELOW ARE INTERNAL FUNCTIONS USED INSIDE THE LIBRARY
            * THIS SHOULD NOT BE OVERWRITTEN
            */
        
        var _INTERNAL_DATA = {
            isInit: false,
            initFns: [],
            orientFns:[],
            winResizeFns: [],
            winResizeTimer: 0,
            winResizeTimeout: 300,
            winResizeWidth: -1,
            prefix: null,
            showLogs: true,
            keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
            googleFontDefault: "Open+Sans:300,400,600:latin",
            googleFontURL: "https://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js"
        };
        
        var _initSystem = function() {
            try {
                $window.requestAnimationFrame = $window.mozRequestAnimationFrame ||
                $window.mozRequestAnimationFrame ||
                $window.webkitRequestAnimationFrame || 
                $window.msRequestAnimationFrame;
            } catch( e ) {}
            _INTERNAL_DATA.winResizeWidth = getPageDimentions().width;
            $document.addEventListener( "DOMContentLoaded", _loadCompleted );
            $window.addEventListener( "load", _loadCompleted );
            $window.addEventListener( "resize" , function() {
                windowResize();
            });
            $window.addEventListener( "orientationchange" , function() {
                orientationChange();
            });  
        };
        
        var _loadCompleted = function() {
            $document.removeEventListener( "DOMContentLoaded", _loadCompleted );
            $window.removeEventListener( "load", _loadCompleted );
            init(function() {
                log( "initialized utility.js on strict mode." );
                Object.preventExtensions( $window.utility );
                Object.seal( $window.utility );
            });
        };
        
        function _getScrollEvents() {
           return ( "DOMMouseScroll wheel mousewheel" ).split( " " );
        };
        
        function _preventDefault( e ) {
            e = e || $window.event;
            if ( e.preventDefault ) {
                e.preventDefault();
                e.stopPropagation();
            }
            e.returnValue = false;
        };

        function _preventDefaultForScrollKeys( e ) {
            if ( ( {37:1, 38:1, 39:1, 40:1} )[ e.keyCode ] ) {
                _preventDefault( e );
                return false;
            }
        };
        
        function _isResourceExists( filename, filetype ) {
            var targetelement = ( filetype === "js" ) ? "script" : ( filetype === "css" ) ? "link" : "none";
            var result;
            var key;
            if ( filetype === "js" ) {
                key = "src";
            } else if ( filetype === "css" ) {
                key = "href";
            }
            forEvery( getElement( targetelement, "TAG" ), function( value ) {
                if ( value.getAttribute( key ) ) {
                    if ( value.getAttribute( key ) === filename ) {
                        result = value;
                        return;
                    }
                }
            })
            return result;
        };
        
        _initSystem();

        
        return {
            addOneTimeEventListener: addOneTimeEventListener,
            allowLogging: allowLogging,
            allowPageScrolling: allowPageScrolling,
            appendDOM: appendDOM,
            base64ToBlob: base64ToBlob,
            base64ToUTF8: base64ToUTF8,
            base64ToObjectURL: base64ToObjectURL,
            commaSeparateNumber: commaSeparateNumber,
            extendSuperFunction: extendSuperFunction,
            forEvery: forEvery,
            forEveryKey: forEveryKey,
            getBrowser: getBrowser,
            getCookie: getCookie,
            getDate: getDate,
            getPageOrientation: getPageOrientation,
            getPageDimentions: getPageDimentions,
            getPrefix: getPrefix,
            getElement: getElement,
            getParent: getParent,
            getURLParameter: getURLParameter,
            init: init,
            isUndefined: isUndefined,
            isRestrictedMode: isRestrictedMode,
            isTouchDevice: isTouchDevice,
            isMobile:isMobile,
            log: log,
            loadResource: loadResource,
            loadGoogleFonts: loadGoogleFonts,
            mergeJSON: mergeJSON,
            onPageLoad: onPageLoad,
            onWindowResize: onWindowResize,
            orientationChange: orientationChange,
            onOrientationChange: onOrientationChange,
            prependDOM: prependDOM,
            randomize: randomize,
            removeDOM: removeDOM,
            scrollTo: scrollTo,
            setCookie: setCookie,
            setJSONtoDOM: setJSONtoDOM,
            smoothStep: smoothStep,
            splice: splice,
            unloadResource: unloadResource,
            utf8ToBase64: utf8ToBase64,
            windowResize: windowResize
        };

    })();

    /**
    Object.defineProperty( $window, "utility", {
        enumerable: true,
        configurable: false,
        get: function() { return utility; },
        set: function( val ) {
            utility = val;
        }
    });
    **/
})( typeof window !== "undefined" ? window : this, document );