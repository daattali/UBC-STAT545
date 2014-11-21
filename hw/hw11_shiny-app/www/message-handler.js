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

Shiny.addCustomMessageHandler("equalizeHeight",
  function(message) {
    equalizeHeight(message.target, message.by);
  }
);
