/**
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: April 21, 2017    Updated: XXX XX, XXXX
    Sputnik Javascript Utility
    v 1.0.0  
**/

(function( $window, $document, $parent ) {
	"use strict";
	
	if ( typeof $window.sputnik1 !== "undefined" ) {
        console.error( "sputnik1 has already been initialized", "ERROR" );
        return;
    }

    if ( typeof $window.webkit === "undefined" ) {
        console.error( "[ ERROR ] Luna can only be used inside an iOS application" );
    } else {
    	console.info( "[ Happy Coding! from Sputnik 1 ]" );
    }

	$window.sputnik1 = (function() {

		function init() {
			//1. Check if the current window is Luna
			_INTERNAL_DATA.isLuna = typeof $window.luna !== "undefined";
			
			var messageListener = function( event ) { 
				$window.removeEventListener( "message", messageListener, false ); 
			};
			var unloadListener = function( event ) { 
				$window.removeEventListener( "message", messageListener, false ); 
				$window.removeEventListener( "unload", unloadListener, false );
				event.preventDefault();
			};

			if( _INTERNAL_DATA.isLuna ) {
				//2.a If is Luna try to check if she resides on an iFrame
				if( isOniFrame() ) {
					//2.a.1 If is on iFrame, try to send message to parent
					if ( $parent ) {
						_INTERNAL_DATA.isHandshakeDone = true;
						_INTERNAL_DATA.messageSource = $parent;
						beamMessage( "Hello Earth!" );
						messageListener = function( event ) {
							//console.log("This is Luna. and your message was: " + event.data);
							if( event.data !== "Hello Luna!" ) {
								$window.luna.runJSCommand( event.data );
								console.info( "This is Luna, and your message was: [ *** Secret Code *** ]" );
							} else {
								console.info( "This is Luna, and your message was: " + event.data );
							}
						};
						unloadListener = function( event ) {
							$window.removeEventListener( "message", messageListener, false );
							$window.removeEventListener( "unload", unloadListener, false);
							beamMessage( "Goodbye Earth!" );
						  	event.preventDefault();
						};
						console.log("I am Luna on iframe");
					}
				} else {
					console.log("I am Luna on main");
				}
			} else {
				//check if lightning component
				var lightning_luna = apollo11.getElement( "lightning-luna" );
				if( lightning_luna.length > 0 ) {

					var component;
					apollo11.forEvery( lightning_luna, function( element ) {
						//component =  
						element.dataset.mato = {a:"mato"}; 
						element.dataset.sputnik1 = $window.sputnik1;
						//_INTERNAL_DATA.lightning_components.push(  )
					});
				}
				//2.b If it is not luna, check if the current window is top window
				else if( isOniFrame() ) {
					//2.b.1 If it is not luna, and on iFrame, send the message recieved to parent
					console.log("I am NOT Luna on iframe");
					if( $parent ) {
						messageListener = function( event ) {
							if( event.data !== "Hello Earth!" || event.data !== "Goodbye Earth!" ) { return; }
							$parent.postMessage( event.data, event.origin );
				        };
					}
				} else {
					console.log("I am NOT Luna on main");
					messageListener = function( event ) {
						if ( event.data === "Hello Earth!" ) {
							_INTERNAL_DATA.isHandshakeDone = true;
							_INTERNAL_DATA.messageSource = event.source;
							_INTERNAL_DATA.messageOrigin = event.origin;

							console.info( "This is Earth, and your message was: " + event.data )
							console.log( _INTERNAL_DATA.messageOrigin );
							beamMessage( "Hello Luna!" )
							beamMessage( _INTERNAL_DATA.message );
						} else if ( event.data === "Goodbye Earth!" ) {
							_INTERNAL_DATA.isHandshakeDone = false;
							_INTERNAL_DATA.messageSource = undefined;
							_INTERNAL_DATA.messageOrigin = "*";

							console.info( "This is Earth, and your message was: " + event.data );
						}
						return;
					};
				}
			}
			$window.addEventListener( "message", messageListener, false );
			$window.addEventListener( "unload", unloadListener, false );
		};

		function beamMessage( message ) {
			if( _INTERNAL_DATA.isLuna && !isOniFrame() ) {
				//run command rightaway
				$window.luna.runJSCommand( message );
			} else {
				if( _INTERNAL_DATA.isHandshakeDone ) {
					_INTERNAL_DATA.messageSource.postMessage( message , _INTERNAL_DATA.messageOrigin );
				} else {
					_INTERNAL_DATA.message = message;
				}
			}
		};

		function sendSOS( name, message ) {
			if( !apollo11.isUndefined( $window.webkit ) ) {
				$window.webkit.messageHandlers[ name ].postMessage( message );
			}
		};

		var _INTERNAL_DATA = {
			isLuna			: false,
			isHandshakeDone	: false,
			messageSource	: undefined,
			messageOrigin	: "*",
			message			: undefined,
			lightning_components	: []
		};

		function isOniFrame() {
            try {
                return $window.self !== $window.top;
            } catch ( e ) {
                return true;
            }
        };

		init();

		return {
			beamMessage		: beamMessage,
			sendSOS			: sendSOS
		};

	})();

})( typeof window !== "undefined" ? window : this, document, typeof window !== "undefined" ? window.parent : this.parent );
