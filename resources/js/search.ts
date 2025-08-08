
/* REQUIRES autocomplete-url attribute */
/* REQUIRES autocomplete-hidden-field-id attribute */
window.search = function (inp) {

  let url = inp.attributes["search-url"].value;

  let search_results_id= inp.attributes["search-results-id"].value;

  console.log(search_results_id);

  let search_results = document.getElementById(search_results_id);

  /*the autocomplete function takes two arguments,
  the text field element and an array of possible autocompleted values:*/
  let currentFocus;
  /*execute a function when someone writes in the text field:*/
  inp.addEventListener("input", async function(e) {
    let a, b, i, val = this.value;

    /* fetch search result */
    let html_results = await fetch(url + "/" + inp.value, {
      method: "GET",
      headers: { "Accept": "text/html" },
    })
    .then((r) => r.text())
    .then((r) => r);

    search_results.innerHTML = html_results;

  });
//   /*execute a function presses a key on the keyboard:*/
//   inp.addEventListener("keydown", function(e) {
//       var x = document.getElementById(this.id + "autocomplete-list");
//       if (x) x = x.getElementsByTagName("div");
//       if (e.keyCode == 40) {
//         console.log("TEST");
//         /*If the arrow DOWN key is pressed,
//         increase the currentFocus variable:*/
//         currentFocus++;
//         /*and and make the current item more visible:*/
//         addActive(x);
//       } else if (e.keyCode == 38) { //up
//         /*If the arrow UP key is pressed,
//         decrease the currentFocus variable:*/
//         currentFocus--;
//         /*and and make the current item more visible:*/
//         addActive(x);
//       } else if (e.keyCode == 13) {
//         /*If the ENTER key is pressed, prevent the form from being submitted,*/
//         e.preventDefault();
//         if (currentFocus > -1) {
//           /*and simulate a click on the "active" item:*/
//           if (x) x[currentFocus].click();
//         }
//       }
//   });
//   function addActive(x) {
//     /*a function to classify an item as "active":*/
//     if (!x) return false;
//     /*start by removing the "active" class on all items:*/
//     removeActive(x);
//     if (currentFocus >= x.length) currentFocus = 0;
//     if (currentFocus < 0) currentFocus = (x.length - 1);
//     /*add class "autocomplete-active":*/
//     x[currentFocus].classList.add("autocomplete-active");
//   }
//   function removeActive(x) {
//     /*a function to remove the "active" class from all autocomplete items:*/
//     for (var i = 0; i < x.length; i++) {
//       x[i].classList.remove("autocomplete-active");
//     }
//   }
//   function closeAllLists(elmnt) {
//     /*close all autocomplete lists in the document,
//     except the one passed as an argument:*/
//     var x = document.getElementsByClassName("autocomplete-items");
//     for (var i = 0; i < x.length; i++) {
//       if (elmnt != x[i] && elmnt != inp) {
//         x[i].parentNode.removeChild(x[i]);
//       }
//     }
//   }

// /*execute a function when someone clicks in the document:*/
//   document.addEventListener("click", function (e) {
//     var x = document.getElementsByClassName("autocomplete");
//     for (let i = 0; i < x.length; i++ ) {
//       x[i].value = x[i].getAttribute("previous-value");
//     }

//     closeAllLists(e.target);
//   });
} 


