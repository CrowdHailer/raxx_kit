/* jshint esnext: true */
'use strict';

// Log levels
export var LOG_LEVELS = {
  all: 0,
  debug: 1,
  info: 2,
  warn: 3,
  error: 4,
  none: 5
};

import { argsToArray } from "./index";

export function wrap(logger, settings){
  var prefix;
  var notices = [];
  if (settings.prefix){
    prefix = "[" + settings.prefix + "]";
    notices = notices.concat(prefix);
  }
  var logLevel = LOG_LEVELS[settings.logLevel];
  function log(){
    if (logLevel <= LOG_LEVELS.all) {
      logger.log.apply(logger, notices.concat(argsToArray(arguments)));
    }
  }
  function debug(){
    if (logLevel <= LOG_LEVELS.debug) {
      logger.debug.apply(logger, notices.concat(argsToArray(arguments)));
    }
  }
  function info(){
    if (logLevel <= LOG_LEVELS.info) {
      logger.info.apply(logger, notices.concat(argsToArray(arguments)));
    }
  }
  function warn(a){
    if (logLevel <= LOG_LEVELS.warn) {
      logger.warn.apply(logger, notices.concat(argsToArray(arguments)));
    }
  }
  function error(e){
    if (logLevel <= LOG_LEVELS.error) {
      logger.error.apply(logger, notices.concat(argsToArray(arguments)));
    }
  }
  return {
    log: log,
    debug: debug,
    info: info,
    warn: warn,
    error: error,
  };
}

export var development = {
  log: function(){
    var args = argsToArray(arguments);
    window.console.log.apply(window.console, args);
  },
  debug: function(){
    var args = argsToArray(arguments);
    window.console.debug.apply(window.console, args);
  },
  info: function(){
    var args = argsToArray(arguments);
    window.console.info.apply(window.console, args);
  },
  warn: function(){
    var args = argsToArray(arguments);
    window.console.warn.apply(window.console, args);
  },
  error: function(e){
    var args = argsToArray(arguments);
    var error = args[args.length - 1];
    window.console.info.apply(window.console, args);
    throw error;
  }
};
