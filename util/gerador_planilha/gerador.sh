#!/bin/bash

# Script para extrair informações de itens de um feed RSS de podcast
# e formatá-las como: TítuloCompleto;Autor;Instituição;AAAA-MM-DD

# Verifica se um nome de arquivo foi fornecido
if [ -z "$1" ]; then
  echo "Uso: $0 <arquivo_rss>"
  exit 1
fi

RSS_FILE="$1"

# Verifica se o arquivo existe e pode ser lido
if [ ! -f "$RSS_FILE" ] || [ ! -r "$RSS_FILE" ]; then
  echo "Erro: Arquivo '$RSS_FILE' não encontrado ou sem permissão de leitura."
  exit 1
fi

# Usa gawk para processar o arquivo RSS
gawk '
BEGIN {
    RS = "</item>"
    OFS = ";"
    FS = "\n"
    months["Jan"] = "01"; months["Feb"] = "02"; months["Mar"] = "03";
    months["Apr"] = "04"; months["May"] = "05"; months["Jun"] = "06";
    months["Jul"] = "07"; months["Aug"] = "08"; months["Sep"] = "09";
    months["Oct"] = "10"; months["Nov"] = "11"; months["Dec"] = "12";
}

# Ignora cabeçalho e tags de canal
/^[[:space:]]*<\?xml |^[[:space:]]*<rss |^[[:space:]]*<channel>/ { next }

# Processa cada registro <item>
{
    # Inicializa variáveis para cada item
    original_title = "" # Para guardar o título completo como lido
    pubDate_str = ""
    author = "N/A"      # Valor padrão se o padrão não for encontrado no título
    institution = "N/A" # Valor padrão
    formattedDate = "N/A"

    # Extrai o conteúdo COMPLETO da tag <title> (lidando com CDATA)
    if (match($0, /<title>(<!\[CDATA\[)?(.*?)(]]>)?<\/title>/, t_arr)) {
        original_title = t_arr[2]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", original_title) # Limpa espaços nas bordas
    }

    # Extrai o conteúdo da tag <pubDate>
    if (match($0, /<pubDate>([^<]+)<\/pubDate>/, d_arr)) {
        pubDate_str = d_arr[1]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", pubDate_str)
    }

    # Prossegue apenas se tivermos título e data
    if (original_title != "" && pubDate_str != "") {

        # --- Tenta EXTRAIR Autor e Instituição do Título Original ---
        # NÃO modificamos mais o 'original_title' aqui.
        # Apenas tentamos encontrar o padrão nele.
        # Regex:   ^(.*)             ,[[:space:]]+(com|with)[[:space:]]+(.*)         [[:space:]]+\((.*)\)      [[:space:]]*$
        # Grupo 1: Texto antes      2: "com" ou "with"                  3: Autor         4: Instituição
        if (match(original_title, /^(.*),[[:space:]]+(com|with)[[:space:]]+(.*)[[:space:]]+\((.*)\)[[:space:]]*$/, title_parts)) {
             # Se o padrão foi encontrado, extrai autor e instituição
             author      = title_parts[3] # Grupo 3 é o Autor
             institution = title_parts[4] # Grupo 4 é a Instituição

             # Limpa espaços extras dos grupos capturados
             gsub(/^[[:space:]]+|[[:space:]]+$/, "", author)
             gsub(/^[[:space:]]+|[[:space:]]+$/, "", institution)
        }
        # Se o 'match' falhar, 'author' e 'institution' permanecem "N/A" (seus valores padrão)


        # --- Processa a Data (lógica inalterada) ---
        if (match(pubDate_str, /[A-Za-z]+,[[:space:]]+([0-9]{1,2})[[:space:]]+([A-Za-z]{3})[[:space:]]+([0-9]{4})/, date_parts)) {
            day = sprintf("%02d", date_parts[1])
            month_str = date_parts[2]
            year = date_parts[3]
            month_num = months[month_str]

            if (month_num != "") {
                time_spec = year " " month_num " " day " 00 00 00"
                timestamp = mktime(time_spec)
                if (timestamp != -1) {
                     formattedDate = strftime("%Y-%m-%d", timestamp)
                } else {
                     formattedDate = "DateParseError(mktime)"
                }
            } else {
                 formattedDate = "DateParseError(Month:" month_str ")"
            }
        } else {
             formattedDate = "DateParseError(Format)"
        }

        # Imprime o resultado final: Título Original Completo; Autor Extraído; Instituição Extraída; Data Formatada
        print original_title, author, institution, formattedDate
    }
}
' "$RSS_FILE"

exit 0
