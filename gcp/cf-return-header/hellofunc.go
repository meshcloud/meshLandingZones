package hellofunc

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func HelloThomas(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello, GCP!")
}

// ReturnHeader returns the original headers of the caller
// We use this function in our meshstack tests
func ReturnHeader(w http.ResponseWriter, r *http.Request) {
	res, err := json.Marshal(r.Header)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "Could not marshal headers: '%v'", err)
		return
	}

	w.Write(res)
}
