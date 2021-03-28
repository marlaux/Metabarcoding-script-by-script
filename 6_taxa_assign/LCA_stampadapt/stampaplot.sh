
TABLE="results.primersX_assign.hits"

grep "Arthropoda" "${TABLE}" | \
awk 'BEGIN {FS = "\t"}
     {stampa[$3] += $2}
     END {for (similarity in stampa) {
              print similarity, stampa[similarity]
         }}' | sort -k1,1n > "${TABLE/.hits/.data}"
