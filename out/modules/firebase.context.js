(function(){var i,e,r;e=require("firebase"),i=require("sublime-error"),i.mixins.value(),r=function(){function r(r){i.Throw.isUnspecified(r,"Firebase URL"),this.ref=new e(r)}return r.prototype.set=function(e,r){var t;return i.Throw.isUnspecified(e,"path"),i.Throw.isUnspecified(r,"data"),t=this.ref.child(e),t.set(r)},r.prototype.push=function(e,r){var t;return i.Throw.isUnspecified(e,"path"),i.Throw.isUnspecified(r,"data"),t=this.ref.child(e),t.push(r)},r.prototype.remove=function(e){var r;return i.Throw.isUnspecified(e,"path"),r=this.ref.child(e),r.remove()},r.prototype.update=function(e,r){var t;return i.Throw.isUnspecified(e,"path"),i.Throw.isUnspecified(r,"data"),t=this.ref.child(e),t.update(r)},r.prototype.query=function(e,r){var t;return i.Throw.isUnspecified(e,"path"),t=this.ref.child(e),r&&r.limit&&r.limit>0&&(t=t.limit(r.limit)),r&&r.order&&(t=t.orderByChild(r.order)),t},r}(),module.exports=r}).call(this);
