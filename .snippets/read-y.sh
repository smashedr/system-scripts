
until [[ $VAR =~ y|n ]];do
    read -r -p "Proceed? (y/n) " -n 1 VAR
    VAR=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]')
    echo
done

echo "${VAR}"
