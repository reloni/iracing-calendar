function toggleFavorite(e)
{
  if(e.target.checked)
  {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", `http://localhost.charlesproxy.com:9000/setFavoriteStatus?uuid=${e.target.getAttribute('serieUuid')}&isFavorite=true`, true);
    xhr.send();
  }
  else
  {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", `http://localhost.charlesproxy.com:9000/setFavoriteStatus?uuid=${e.target.getAttribute('serieUuid')}&isFavorite=false`, true);
    xhr.send();
  }
}