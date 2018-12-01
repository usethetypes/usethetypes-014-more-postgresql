$(() => {
  const e = $("#date-time");

  function updateDateTime() {
    e.text(new Date().toString());
  }

  updateDateTime();
  setInterval(updateDateTime, 500);
});
