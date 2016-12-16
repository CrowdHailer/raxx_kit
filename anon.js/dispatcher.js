function Dispatcher(handlers, logger){
  this.dispatch = function(){
    var args = arguments;
    handlers.forEach(function(handler){
      try {
        handler.apply({}, args);
      } catch(e) {
        logger.error(e);
      }
    });

    if (handlers.length === 0) {
      logger.warn.apply(logger, args);
    } else {
      logger.info.apply(logger, args);
    }
  };
  this.register = function(handler){
    return new Dispatcher(handlers.concat(handler), logger);
  };
}

export function create(logger){
  return new Dispatcher([], logger);
}
export default Dispatcher;
