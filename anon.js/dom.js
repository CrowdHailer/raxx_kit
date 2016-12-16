export function matches(selector, element) {
  // DEBT this should be removed when possible
  element.matches = element.matches || element.mozMatchesSelector || element.msMatchesSelector || element.oMatchesSelector || element.webkitMatchesSelector;
  return element.matches(selector);
}

export function closest(selector, element) {
  // DEBT there is a native implementation of this
  while (element) {
    if (matches(selector, element)) { return element; }
    element = element.parentElement;
  }
}

export function isDescendant(parent, child) {
  var node = child.parentNode;
  while (node) {
    if (node == parent) { return true; }
    node = node.parentNode;
  }
  return false;
}

export function Delegator(root){
  this.on = function(eventName, selector, callback){
    root.addEventListener(eventName, function(evt){
      var $trigger = closest(selector, evt.target);
      if ($trigger && isDescendant(root, $trigger)) {
        evt.trigger = $trigger;
        return callback(evt);
      }
    });
  };
}

export function ready(fn) {
  if (document.readyState !== "loading"){
    fn();
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
}
