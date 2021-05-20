function check_helm_chart {

  chart=$1

  found=`helm search repo $chart | tail -n +2`

  if [ "$found" = "No results found" ]; then
  	 echo "Helm chart $chart not found"
  	 exit
  fi	

  ch=`echo $found | cut -d" " -f 1`
  v=`echo $found | cut -d" " -f 2`

  echo "Helm chart $ch $v found"
} 

function check_executables {
  execs=(helm kubectl)
  for e in ${execs[@]}; do
    if ! command -v $e &> /dev/null ; then
      echo "$e is required"
      exit
    fi  
  done
}