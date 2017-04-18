(function( $window, $document ) {
 "use strict";

      var utility = $window.utility;
 
      $window.App = (function(){

            function init(){};

            function activatePage( ){

              var app_content = utility.getElement("app_content", "id");
              var webview;
              var avplayer;

              $window.URL = $window.URL || $window.webkitURL;

              utility.getElement( "icon0", "id" ).addEventListener( "click", function() {
                iOS.changeIcon({name:"de"}).then(function(result){
                  iOS.debug( "iOS.changeIcon: " + result );
                },function(error){
                  iOS.debug( "iOS.changeIcon: " + error );
                })
              });
              utility.getElement( "icon1", "id" ).addEventListener( "click", function() {
                iOS.changeIcon({name:"bluemoon"}).then(function(result){
                  iOS.debug( "iOS.changeIcon: " + result );
                },function(error){
                  iOS.debug( "iOS.changeIcon: " + error );
                })
              });
              utility.getElement( "icon2", "id" ).addEventListener( "click", function() {
                iOS.changeIcon({name:"redmoon"}).then(function(result){
                  iOS.debug( "iOS.changeIcon: " + result );
                },function(error){
                  iOS.debug( "iOS.changeIcon: " + error );
                })
              });

              utility.getElement( "getvideo2", "id" ).addEventListener( "click", function() {
                  iOS.getVideoFile({
                    filename:   "video 2.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    iOS.debug( "iOS.takeVideo:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    iOS.getNewAVPlayer({
                      video_file: video_file,
                      property: {
                        frame: {
                          height:   320,
                          y:        300
                        },
                        opacity:    1,
                        autoPlay:   true,
                        mute:       false
                      }
                    }).then(function( avplayer2 ){

                      iOS.getMainWebview().appendAVPlayer({
                        avplayer: avplayer2,
                        isFixed: false
                      }).then( function(result){
                        iOS.debug( "appendAVPlayer: " + result )
                      });


                      iOS.debug( "iOS.getNewAVPlayer: " +  avplayer2.getID());
                    }, function(error){
                      iOS.debug( error );
                    })



                  },function(error){
                    iOS.debug( error );
                  });


              });

              utility.getElement( "getvideo1", "id" ).addEventListener( "click", function() {
                  
                  iOS.getVideoFile({
                    filename:   "video 7_4k_60fps.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    iOS.debug( "iOS.takeVideo:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    iOS.getNewAVPlayer({
                      video_file: video_file,
                      property: {
                        opacity:    1,
                        autoPlay:   true,
                        mute:       false
                      }
                    }).then(function( _avplayer ){
                      
                      avplayer = _avplayer;

                      iOS.getMainWebview().appendAVPlayer({
                        avplayer: avplayer,
                        isFixed: true
                      }).then( function(result){
                        iOS.debug( "appendAVPlayer: " + result )
                      });


                      iOS.debug( "iOS.getNewAVPlayer: " +  avplayer.getID());
                    }, function(error){
                      iOS.debug( error );
                    })



                  },function(error){
                    iOS.debug( error );
                  });


              });

              utility.getElement( "play", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.play().then( function(result){
                    iOS.debug( "avplayer.play: " + result );
                  });
                }
              });
              utility.getElement( "pause", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.pause().then( function(result){
                    iOS.debug( "avplayer.pause: " + result );
                  });
                }
              });
              utility.getElement( "seek", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.seek({seconds:2.0}).then( function(result){
                    iOS.debug( "avplayer.seek: " + result );
                  }, function(error){
                    iOS.debug( "avplayer.seek: " + error );
                  });
                }
              });


              utility.getElement( "getVideo", "id" ).addEventListener( "click", function() {
                iOS.takeVideo({from:"VIDEO_LIBRARY"}).then( function(videoFile){
                  iOS.debug( "iOS.takeVideo:" );


                    videoFile.getFullResolutionDOM().then( function( DOM ){
                      iOS.debug( "videoFile.getBase64Binary: YAY" );

                      document.body.appendChild( DOM );

                    }, function(error){
                      iOS.debug( "videoFile.getBase64Binary: " + error );
                    });

                }, function(error){
                  iOS.debug( "iOS.takeVideo: " + error );
                });

                // iOS.getVideoFile({
                //     filename:   "video 1.mp4", //1,2,3,6
                //     path_type:  "document"
                //   }).then(function( videoFile ){
                //     iOS.debug( "iOS.takeVideo:" +  videoFile.getFilename());

                //     // console.log( videoFile )

                //     videoFile.getFullResolutionDOM().then( function( DOM ){
                //       iOS.debug( "videoFile.getBase64Binary: YAY" );

                //       document.body.appendChild( DOM );

                //     }, function(error){
                //       iOS.debug( "videoFile.getBase64Binary: " + error );
                //     });

                //   },function(error){
                //     iOS.debug( error );
                //   });
              });




              utility.getElement( "takePhoto", "id" ).addEventListener( "click", function() {
                iOS.takePhoto({from:"CAMERA"}).then( function(imageFile){
                    iOS.debug( "iOS.takePhoto: OK" );
                    iOS.debug( "iOS.takePhoto: " + imageFile.getFilePath());

                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                    // imageFile.move({
                    //     to:  "Camera Roll",
                    //     isOverwrite: true
                    // }).then(function(url){
                    //     iOS.debug("file.moveFile: " + imageFile.getFilePath())
                    // }, function(error){
                    //     iOS.debug("file.moveFile: " + imageFile)
                    // })

                    imageFile.getFullResolutionDOM().then( function( DOM ){
                      iOS.debug( "imageFile.getBase64Binary: YAY" );

                      document.body.appendChild( DOM );

                    }, function(error){
                      iOS.debug( "imageFile.getBase64Binary: " + error );
                    });

                    // imageFile.getEXIFInfo().then( function(value){
                    //   iOS.debug( value );
                    // }, function(error){
                    //   iOS.debug( "imageFile.getEXIFInfo: " + error );
                    // });

                }, function(error){
                    iOS.debug( "iOS.takePhoto: " + error );
                });
              });

              utility.getElement( "getPhoto", "id" ).addEventListener( "click", function() {
                  iOS.takePhoto({from:"PHOTO_LIBRARY"}).then( function(imageFile){

                    iOS.debug( "webview.takePhoto: " + imageFile.getFilename() + " " + imageFile.getFileExtension());


                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:50}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:10}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getFullResolutionDOM().then( function( DOM ){
                      iOS.debug( "imageFile.getBase64Binary: YAY" );

                      document.body.appendChild( DOM );

                    }, function(error){
                      iOS.debug( "imageFile.getBase64Binary: " + error );
                    });

                    imageFile.getEXIFInfo().then( function(value){
                      iOS.debug( value );
                    }, function(error){
                      iOS.debug( "imageFile.getEXIFInfo: " + error );
                    });



                  }, function(error){
                    iOS.debug( "webview.takePhoto: " + error );
                  })
              });



              utility.getElement( "close", "id" ).addEventListener( "click", function() {
                  webview.setProperty( {frame: {
                        height:   320,
                        y:        300
                      },
                      opacity:0
                    }, { duration:1.0, delay:0 } ).then(function(result){
                      iOS.debug( "webview.setProperty: " + result );
                      iOS.closeWebview( webview ).then(function(result){
                        iOS.debug( "webview.closeWebview: " + result );
                      });
                  });
              });

              utility.getElement( "move", "id" ).addEventListener( "click", function() {

                  iOS.getVideoFile({
                    filename:   "sample.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    iOS.debug( "iOS.getVideoFile:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    video_file.move({
                      to:  "movefolder",
                      isOverwrite: true
                    }).then(function(url){
                      iOS.debug("file.moveFile: " + video_file.getFilePath())
                    }, function(error){
                      iOS.debug("file.moveFile: " + error)
                    })


                  },function(error){

                    iOS.getVideoFile({
                      filename:   "sample.mp4",
                      path:       "movefolder", 
                      path_type:  "document"
                    }).then(function( video_file ){
                      iOS.debug( "iOS.getVideoFile: " +  video_file.getFilename() + " " + video_file.getFileExtension() );

                      video_file.move({
                        to:  "",
                        isOverwrite: true
                      }).then(function(url){
                        iOS.debug("file.moveFile: " + video_file.getFilePath())
                      }, function(error){
                        iOS.debug("file.moveFile: " + error)
                      })


                    },function(error){
                      iOS.debug( error );
                    });

                  });
              });

              utility.getElement( "rename", "id" ).addEventListener( "click", function() {

                  iOS.getFile({
                    filename:   "rename.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    iOS.debug( "iOS.getFile: (old filename) " +  file.getFilename());

                    file.rename({
                      filename:  "newname.mp4"
                    }).then(function(url){
                      iOS.debug( "iOS.getFile: (new filename) " +  file.getFilename());
                    }, function(error){
                      iOS.debug("file.renameFile: " + error)
                    })
                  },function(error){
                    //iOS.debug( error );

                    iOS.getFile({
                      filename:   "newname.mp4",
                      path_type:  "document"
                    }).then(function( file ){
                      iOS.debug( "iOS.getFile: (old filename) " +  file.getFilename());

                      file.rename({
                        filename:  "rename.mp4"
                      }).then(function(url){
                        iOS.debug( "iOS.getFile: (new filename) " +  file.getFilename());
                      }, function(error){
                        iOS.debug("file.renameFile: " + error)
                      })
                    },function(error){
                      iOS.debug( error );
                    });

                  });
              });


              utility.getElement( "copy", "id" ).addEventListener( "click", function() {

                  iOS.getFile({
                    filename:   "video 1.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    iOS.debug( "iOS.getFile: " +  file.getFilename());

                    file.copy({
                      to:  "copyfolder"
                    }).then(function(url){
                      iOS.debug("file.copyFile: " + url)
                    }, function(error){
                      iOS.debug("file.copyFile: " + error)
                    })

                  },function(error){
                    iOS.debug( error );
                  });
              });

              utility.getElement( "delete", "id" ).addEventListener( "click", function() {

                  iOS.getFile({
                    filename:   "video 1.mp4",
                    path: "copyfolder",
                    path_type:  "document"
                  }).then(function( file ){
                    iOS.debug( "iOS.getFile: " +  file.getFilename());

                    file.delete().then(function(result){
                      iOS.debug("file.delete: " + result)
                    }, function(error){
                      iOS.debug("file.delete: " + error)
                    })

                  },function(error){
                    iOS.debug( error );
                  });

                  
              });

              utility.getElement( "download", "id" ).addEventListener( "click", function() {

                // iOS.getFile({
                //   path    : "http://all-free-download.com/free-photos/download/english_love_picture_burning_165644_download.html"
                // }).then( function(file){

                //   iOS.debug("iOS.getFile: " + file.getFilePath())

                //   file.onDownload().then( function(result){
                //     iOS.debug("file.onDownload: " + result)
                //   }, function(error){
                //     iOS.debug("file.onDownload: " + error)
                //   });

                //   file.onDownloading(function(progress){
                //     iOS.debug( "onDownloading: " + progress + "%" );
                //   }).then(function(result){
                //     iOS.debug( "file.onDownloading: " + result );
                //   }, function(error){
                //     iOS.debug( "file.onDownloading: " + error );
                //   });

                //   file.onDownloaded().then( function(result){
                //     iOS.debug("file.onDownloaded: " + result)
                //   }, function(error){
                //     iOS.debug("file.onDownloaded: " + error)
                //   });

                //   file.download({
                //     isOverwrite   : true
                //   }).then(function(result){
                //     iOS.debug("file.download: ok" + result)
                //   },function(error){
                //     iOS.debug("file.download: error" + error)
                //   });

                // }, function(error){
                //   iOS.debug("iOS.getFile: " + error)
                // })



                iOS.getImageFile({
                  path    : "https://goo.gl/cl7FKy"
                }).then( function(file){

                  iOS.debug("iOS.getFile1: " )
                  iOS.debug(file)

                  file.onDownload().then( function(result){
                    iOS.debug("file.onDownload1: " + result)
                  }, function(error){
                    iOS.debug("file.onDownload1: " + error)
                  });

                  file.onDownloading(function(progress){
                    iOS.debug( "onDownloading1: " + progress + "%" );
                  }).then(function(result){
                    iOS.debug( "file.onDownloading1: " + result );
                  }, function(error){
                    iOS.debug( "file.onDownloading1: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    iOS.debug("file.onDownloaded1: ")
                    iOS.debug(result)

                    // file.copy({
                    //   to:  "copyfolder"
                    // }).then(function(url){
                    //   iOS.debug("file.copyFile: " + url)
                    // }, function(error){
                    //   iOS.debug("file.copyFile: " + error)
                    // })

                    file.getResizedDOM({quality:10}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM1: " );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM1: " + error );
                    });

                    file.share().then(function(resut){
                      iOS.debug("file.share: " + resut)
                    },function(error){
                      iOS.debug("file.share: " + error)
                    });


                  }, function(error){
                    iOS.debug("file.onDownloaded1: " + error)
                  });

                  file.download({
                    isOverwrite   : true,
                  }).then(function(resut){
                    iOS.debug("file.download1: " + resut)
                  },function(error){
                    iOS.debug("file.download1: " + error)
                  });


                }, function(error){
                  iOS.debug("iOS.getFile1: " + error)
                })






                iOS.getImageFile({
                  path    : "https://lumiere-a.akamaihd.net/v1/images/image_ccc4b657.jpeg"
                }).then( function(file){

                  iOS.debug("iOS.getFile: " + file.getFilePath())

                  file.onDownload().then( function(result){
                    iOS.debug("file.onDownload: " + result)
                  }, function(error){
                    iOS.debug("file.onDownload: " + error)
                  });

                  file.onDownloading(function(progress){
                    iOS.debug( "onDownloading: " + progress + "%" );
                  }).then(function(result){
                    iOS.debug( "file.onDownloading: " + result );
                  }, function(error){
                    iOS.debug( "file.onDownloading: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    iOS.debug("file.onDownloaded: ")
                    iOS.debug(result)

                    file.getResizedDOM({quality:10}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: " );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                  }, function(error){
                    iOS.debug("file.onDownloaded: " + error)
                  });

                  file.download({
                    isOverwrite   : true
                  }).then(function(resut){
                    iOS.debug("file.download: " + resut)
                  },function(error){
                    iOS.debug("file.download: " + error)
                  });

                }, function(error){
                  iOS.debug("iOS.getFile: " + error)
                })





              });



              utility.getElement( "show", "id" ).addEventListener( "click", function() {

                iOS.getHtmlFile({
                    filename:   "subindex.html",
                    path:       "resource",
                    path_type:  "bundle"
                }).then( function( html_file ){
                    iOS.debug( "iOS.getHtmlFile: " );
                    iOS.debug( html_file )

                    iOS.getNewWebview({
                      html_file: html_file,
                      property: {
                        frame: {
                          height:   320,
                          y:        0
                        },
                        opacity:    0
                      }
                    }).then( function( result ){

                      webview = result;

                      iOS.debug( "iOS.getNewWebview: " + webview.getID() );

                      webview.load().then(function(result){
                        iOS.debug( "webview.load: " + result );
                      });

                      webview.onLoad().then(function(result){
                        iOS.debug( "webview.onLoad: " + result );
                      });

                      webview.onLoading(function(progress){
                        iOS.debug( "Loading: " + progress + "%" );
                      }).then(function(result){
                        iOS.debug( "webview.onLoading: " + result );
                      });

                      webview.onLoaded().then(function(result){
                        iOS.debug( "webview.onLoaded: " + result );

                        webview.setProperty( {frame: {
                            height:   320,
                            y:        100
                          },
                          opacity:1.0
                        }, { duration:1.0, delay:0 } ).then(function(result){
                          iOS.debug( "webview.setProperty: " + result );
                        });

                      });

                    },function( error ){
                      iOS.debug( error )
                    });


                }, function(error){
                    iOS.debug( error )
                })

              });


              utility.getElement( "unzip", "id" ).addEventListener( "click", function() {

                iOS.getZipFile({
                  path    : "https://s3.amazonaws.com/data.openaddresses.io/runs/176076/br/am/statewide.zip"
                }).then( function(file){

                  iOS.debug("iOS.getFile: " )
                  iOS.debug(file)

                  file.onDownload().then( function(result){
                    iOS.debug("file.onDownload: " + result)
                  }, function(error){
                    iOS.debug("file.onDownload: " + error)
                  });

                  file.onDownloading(function(progress){
                    iOS.debug( "onDownloading: " + progress + "%" );
                  }).then(function(result){
                    iOS.debug( "file.onDownloading: " + result );
                  }, function(error){
                    iOS.debug( "file.onDownloading: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    iOS.debug("file.onDownloaded: ")
                    iOS.debug(file)

                    file.onUnzip().then(function(result){
                      iOS.debug("file.onUnzip: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      iOS.debug("file.onUnzipped: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      iOS.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      iOS.debug("file.onUnzipping: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      iOS.debug("file.unzip: " + result)
                    }, function(error){
                      iOS.debug("file.unzip: " + error)
                    })

                  }, function(error){
                    iOS.debug("file.onDownloaded: " + error)
                  });

                  file.download({
                    isOverwrite   : true,
                  }).then(function(resut){
                    iOS.debug("file.download: " + resut)
                  },function(error){
                    iOS.debug("file.download: " + error)
                  });

                }, function(error){
                  iOS.debug("iOS.getFile: " + error)
                })


                iOS.getZipFile({
                    filename:   "imagefiles.zip" //myfolder.zip imagefiles.zip
                }).then( function( file ){
                    iOS.debug( "iOS.getZipFile: ");
                    iOS.debug(file)

                    file.onUnzip().then(function(result){
                      iOS.debug("file.onUnzip: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      iOS.debug("file.onUnzipped: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      iOS.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      iOS.debug("file.onUnzipping: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      iOS.debug("file.unzip: " + result)
                    }, function(error){
                      iOS.debug("file.unzip: " + error)
                    })

                });

                iOS.getZipFile({
                    filename:   "myfolder.zip" //myfolder.zip imagefiles.zip
                }).then( function( file ){
                    iOS.debug( "iOS.getZipFile: ");
                    iOS.debug(file)

                    file.onUnzip().then(function(result){
                      iOS.debug("file.onUnzip: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      iOS.debug("file.onUnzipped: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      iOS.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      iOS.debug("file.onUnzipping: " + result)
                    }, function(error){
                      iOS.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      iOS.debug("file.unzip: " + result)
                    }, function(error){
                      iOS.debug("file.unzip: " + error)
                    })

                });
              });

              utility.getElement( "zip", "id" ).addEventListener( "click", function() {
                iOS.getImageFile({
                  filename: "spiderman.jpg",
                  path_type: "document"
                }).then(function(file){

                  file.zip({
                    filename    : "spiderman.zip",
                    isOverwrite : true
                  }).then(function(result){
                    iOS.debug("file.zip: " + result)
                  }, function(error){
                    iOS.debug("file.zip: " + error)
                  })

                  file.onZip().then(function(result){
                    iOS.debug("file.onZip: " + result)
                  }, function(error){
                    iOS.debug("file.onZip: " + error)
                  })
                  file.onZipped().then(function(zipFile){
                    iOS.debug("file.onZipped: ")
                    iOS.debug( zipFile.toJSON() )
                  }, function(error){
                    iOS.debug("file.onZipped: " + error)
                  })
                  file.onZipping(function(progress){
                    iOS.debug("file.onZipping: " + progress)
                  }).then(function(result){
                    iOS.debug("file.onZipping: " + result)
                  }, function(error){
                    iOS.debug("file.onZipping: " + error)
                  });

                },function(error){
                  iOS.debug("iOS.getImageFile: " + error)
                });
              });



              utility.getElement( "filecol", "id" ).addEventListener( "click", function() {

                var listFiles = function( path ) {
                  iOS.getFileCollection({
                    path: path,
                    path_type: "document"
                  }).then(function( fileCollection ){
                    iOS.debug("iOS.getFileCollection: ")
                    iOS.debug( "No of Files: " + fileCollection.getFiles().length )

                    utility.forEvery( fileCollection.getFiles(), function(file){
                      
                      if(file.objectType() === "ImageFile") {
                        file.getResizedDOM({quality:100, height: 150}).then( function( DOM ){
                          iOS.debug( "imageFile.getResizedDOM: " );
                          document.body.appendChild( DOM );
                        }, function(error){
                          iOS.debug( "imageFile.getResizedDOM: " + error );
                        });
                      }

                      if(file.objectType() === "File") {
                        iOS.debug( file.toJSON() )
                        if( file.getFilename() === ".DS_Store" ) {
                          file.delete().then(function(result){
                            iOS.debug("deleted" + file.getFilename())
                          }, function(error){
                            iOS.debug(error)
                          })
                        }
                      }

                      if(file.objectType() === "ZipFile") {
                        file.unzip({
                          to: "unzipfolder"
                        }).then(function(result){
                          iOS.debug("file.unzip: " + result)
                        }, function(error){
                          iOS.debug("file.unzip: " + error)
                        })

                        file.onUnzip().then(function(result){
                          iOS.debug("file.onUnzip: " + result)
                        }, function(error){
                          iOS.debug("file.onUnzip: " + error)
                        })
                        file.onUnzipped().then(function(result){
                          iOS.debug("file.onUnzipped: " + result)
                        }, function(error){
                          iOS.debug("file.onUnzipped: " + error)
                        })
                        file.onUnzipping(function(progress){
                          iOS.debug("file.onUnzipping: " + progress)
                        }).then(function(result){
                          iOS.debug("file.onUnzipping: " + result)
                        }, function(error){
                          iOS.debug("file.onUnzipping: " + error)
                        })
                      }
                    });

                    fileCollection.share().then(function(resut){
                      iOS.debug("fileCollection.share: " + resut)
                    },function(error){
                      iOS.debug("fileCollection.share: " + error)
                    });

                    utility.forEvery( fileCollection.getDirectories(), function(directory){
                      //listFiles(directory)
                    });

                  }, function(error){
                    iOS.debug("iOS.getFileCollection: " + error)
                  });
                };

                //zip3folders
                //zip3files
                listFiles("zip3folders");

                

              });


            };

            


            return {
              init: init,
              activatePage: activatePage
            };
      })();

























 
 })( typeof window !== "undefined" ? window : this, document );
