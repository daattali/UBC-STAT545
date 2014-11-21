// This file listens for messages from the shiny app and
// redirects them to javascript

Shiny.addCustomMessageHandler("show",
  function(message) {
    show(message.id);
  }
);

Shiny.addCustomMessageHandler("hide",
  function(message) {
    hide(message.id);
  }
);

Shiny.addCustomMessageHandler("equalizePlotHeight",
  function(message) {
    equalizePlotHeight(message.target, message.by);
  }
);
