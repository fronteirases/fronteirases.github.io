#!/bin/bash

# Verifica se foi fornecido um arquivo como argumento
if [ $# -ne 1 ]; then
    echo "Uso: $0 arquivo_rss.xml"
    exit 1
fi

# Verifica se o arquivo existe
if [ ! -f "$1" ]; then
    echo "Erro: Arquivo $1 não encontrado"
    exit 1
fi

# Processa o arquivo RSS
while IFS= read -r line || [ -n "$line" ]; do
    # Se encontrar uma linha com <title>
    if echo "$line" | grep -q "<title><!\[CDATA\["; then
        # Extrai o título completo e os parênteses
        title=$(echo "$line" | sed -E 's/.*<title><!\[CDATA\[(.*)\]\]><\/title>.*/\1/')
        
        # Extrai o nome do convidado e a instituição (se existir)
        if [[ $title == *", com "* && $title == *"("* && $title == *")"* ]]; then
            main_title=$(echo "$title" | sed -E 's/(.*), com .*/\1/')
            guest=$(echo "$title" | sed -E 's/.*com (.*) \(.*/\1/')
            institution=$(echo "$title" | sed -E 's/.*\((.*)\).*/\1/')
        elif [[ $title == *", com "* ]]; then
            main_title=$(echo "$title" | sed -E 's/(.*), com .*/\1/')
            guest=$(echo "$title" | sed -E 's/.*com (.*)/\1/')
            institution=""
        else
            main_title="$title"
            guest=""
            institution=""
        fi
        
        # Armazena para uso posterior
        current_title="$main_title"
        current_guest="$guest"
        current_institution="$institution"
    fi
    
    # Se encontrar uma linha com <pubDate>
    if echo "$line" | grep -q "<pubDate>"; then
        # Extrai a data
        pubdate=$(echo "$line" | sed -E 's/.*<pubDate>(.*)<\/pubDate>.*/\1/')
        
        # Converte a data para o formato YYYY-MM-DD
        # Precisa do GNU date para funcionar corretamente
        formatted_date=$(date -d "$pubdate" +"%Y-%m-%d" 2>/dev/null)
        
        # Se a conversão falhar (em alguns sistemas como macOS), tenta uma abordagem alternativa
        if [ -z "$formatted_date" ]; then
            # Extrai componentes da data manualmente
            day=$(echo "$pubdate" | awk '{print $2}')
            month=$(echo "$pubdate" | awk '{print $3}')
            year=$(echo "$pubdate" | awk '{print $4}')
            
            # Converte o mês para número
            case $month in
                Jan) month="01" ;;
                Feb) month="02" ;;
                Mar) month="03" ;;
                Apr) month="04" ;;
                May) month="05" ;;
                Jun) month="06" ;;
                Jul) month="07" ;;
                Aug) month="08" ;;
                Sep) month="09" ;;
                Oct) month="10" ;;
                Nov) month="11" ;;
                Dec) month="12" ;;
            esac
            
            # Formata a data como YYYY-MM-DD
            formatted_date="${year}-${month}-${day}"
        fi
        
        # Se temos um título armazenado, imprime a linha formatada
        if [ -n "$current_title" ]; then
            echo "${current_title}; ${current_guest}; ${current_institution}; ${formatted_date}"
            
            # Limpa as variáveis para o próximo episódio
            current_title=""
            current_guest=""
            current_institution=""
        fi
    fi
done < "$1"
