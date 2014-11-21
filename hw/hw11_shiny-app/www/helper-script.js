function addClass(id, cls) {
  var e = document.getElementById(id);
  cls = " " + cls;
  e.className = e.className.replace(cls,"");
  e.className = e.className + cls;
}

function removeClass(id, cls) {
  var e = document.getElementById(id);
  cls = " " + cls;
  e.className = e.className.replace(cls,"");
}

function show(id) {
  removeClass(id, "hideme");
}

function hide(id) {
  addClass(id, "hideme");
}

function equalizeHeight(target, by) {
	var eBy = document.getElementById(by);
	var width = eBy.scrollWidth;
	var height = width + 200;
	var eTarget = document.getElementById(target);
	eTarget.style.height = height + "px";
	
	Shiny.onInputChange("plotDim", width);
	console.log("A");
}