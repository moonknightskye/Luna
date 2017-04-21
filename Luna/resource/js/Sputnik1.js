(function( $window, $document, $parent ) {
	"use strict";
	
	console.log("Happy Coding! from Sputnik 1");

	$window.Sputnik1 = (function(){

		function init() {
			//1. Check if the current window is Luna
			_INTERNAL_DATA.isLuna = typeof $window.iOS !== "undefined";
			
			var messageListener = undefined;
			if( _INTERNAL_DATA.isLuna ) {
				//2.a If is Luna try to check if she resides on an iFrame
				if( isOniFrame() ) {
					//2.a.1 If is on iFrame, try to send message to parent
					if ( $parent ) {
						_INTERNAL_DATA.isHandshakeDone = true;
						_INTERNAL_DATA.messageSource = $parent;
						beamMessage("Hello Earth!");
						messageListener = function( event ) {
							console.log("This is Luna. and your message was: " + event.data);
							if( event.data !== "Hello Luna!" ) {
								$window.iOS.runJSCommand( event.data  );
							}
						};
						console.log("I am Luna on iframe");
					}
				} else {
					console.log("I am Luna on main");
				}
			} else {
				//2.b If it is not luna, check if the current window is top window
				if( isOniFrame() ) {
					//2.b.1 If it is not luna, and on iFrame, send the message recieved to parent
					console.log("I am NOT Luna on iframe");
					if( $parent ) {
						messageListener = function( event ) {
							if( event.data !== "Hello Earth!" ) { return; }
							$parent.postMessage( event.data, event.origin );
				        };
					}
				} else {
					console.log("I am NOT Luna on main");
					messageListener = function( event ) {
						if( event.data !== "Hello Earth!" ) { return; }
						_INTERNAL_DATA.isHandshakeDone = true;
						_INTERNAL_DATA.messageSource = event.source;
						_INTERNAL_DATA.messageOrigin = event.origin;

						console.log( "Got your greeting! " + event.data )
						beamMessage( "Hello Luna!" )
						beamMessage( _INTERNAL_DATA.message );
						$window.removeEventListener( "message", messageListener, false );
					};
				}
			}

			$window.addEventListener( "message", messageListener, false );
		};

		function beamMessage( message ) {
			if( _INTERNAL_DATA.isLuna && !isOniFrame() ) {
				$window.iOS.runJSCommand( message );
			} else {
				if( _INTERNAL_DATA.isHandshakeDone ) {
					_INTERNAL_DATA.messageSource.postMessage( message , _INTERNAL_DATA.messageOrigin );
				} else {
					_INTERNAL_DATA.message = message;
				}
			}
		};

		var _INTERNAL_DATA = {
			isLuna			: false,
			isHandshakeDone	: false,
			messageSource	: undefined,
			messageOrigin	: "*",
			message			: undefined
		};

		function isOniFrame() {
            try {
                return $window.self !== $window.top;
            } catch (e) {
                return true;
            }
        };

		init();

		return {
			beamMessage		: beamMessage
		};

	})();

})( typeof window !== "undefined" ? window : this, document, typeof window !== "undefined" ? window.parent : this.parent );
