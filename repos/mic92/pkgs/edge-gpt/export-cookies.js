// Copy this into the Browser's javascript console to export cookies as JSON

function exportCookiesAsJSON() {
  // Get all cookies for the current domain
  const cookies = document.cookie.split(";").map(cookie => {
    const [name, value] = cookie.split("=").map(str => str.trim());
    return { name, value };
  });
  
  // Convert cookies array to JSON
  const json = JSON.stringify(cookies.reduce((acc, cookie) => {
    acc[cookie.name] = cookie.value;
    return acc;
  }, {}), null, 2);
  
  // Log the JSON to the console
  console.log(json);
  return json
}

copy(exportCookiesAsJSON());

