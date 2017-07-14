({
  render: function(component, helper) {
    //grab attributes from the component markup
    var classname = component.get("v.iconClass");
    var ariaHidden = component.get("v.ariaHidden");
    var communityName = component.get("v.communityName");
    var nameSpace = component.get("v.lmsNamespace");
    var sprite = component.get("v.sprite");
    var symbolsAnchor = component.get("v.symbolsAnchor");

    //return an svg element w/ the attributes
    var span = document.createElement("span");
    span.setAttribute('class', component.get("v.wrapperClass"));
    span.setAttribute('style', component.get("v.wrapperStyle"));

    var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    svg.setAttribute('class', classname);
    svg.setAttribute('aria-hidden', ariaHidden);
    var xlinkRef =  (!communityName || communityName === '') ? '':'/'+communityName;
    xlinkRef += '/resource/'+nameSpace+'salesforce_lds/assets/icons/'+sprite+'/svg/symbols.svg#'+symbolsAnchor;
    svg.innerHTML = '<use xlink:href="'+xlinkRef+'"></use>';

    span.appendChild(svg);
    return span;
  }
})