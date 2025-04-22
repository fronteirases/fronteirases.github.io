#!/bin/bash

# Define o diretório onde os arquivos .srt estão
SRT_DIR="YouTube/srt"

# Define o nome do arquivo de saída
OUTPUT_FILE="index.md"

# Verifica se o diretório de SRT existe
if [ ! -d "$SRT_DIR" ]; then
  echo "Erro: O diretório '$SRT_DIR' não foi encontrado."
  exit 1
fi

# Escreve o cabeçalho no arquivo de saída (sobrescreve se já existir)
echo "# Índice das Transcrições dos Episódios do Fronteiras da Engenharia de Software" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE" # Adiciona uma linha em branco para melhor formatação

# Controla se algum arquivo foi encontrado
found_files=0

# Itera sobre todos os arquivos .srt no diretório especificado
shopt -s nullglob
for filepath in "$SRT_DIR"/*.srt; do
  # Marca que pelo menos um arquivo foi encontrado
  found_files=1

  # Extrai apenas o nome do arquivo (ex: 2020-06-19-Metodos_Ageis....srt)
  filename=$(basename "$filepath")

  # Remove a extensão .srt do nome do arquivo
  link_text_raw="${filename%.srt}"

  # --- NOVO: Escapa os underscores no texto do link ---
  # Substitui todas as ocorrências de '_' por '\_' no texto que será exibido
  # A dupla barra invertida '\\' é necessária para que o shell interprete como uma barra invertida literal antes do underscore
  escaped_link_text="${link_text_raw//_/\\_}"
  # ----------------------------------------------------

  # Adiciona a linha formatada em Markdown ao arquivo de saída
  # Usa o texto com underscores escapados [entre colchetes]
  # Mantém o caminho original (sem escapar) para o link (entre parênteses)
  echo "- [${escaped_link_text}](./${filepath})" >> "$OUTPUT_FILE"
done
shopt -u nullglob

# Informa o usuário sobre o resultado
if [ $found_files -eq 1 ]; then
  echo "Arquivo '$OUTPUT_FILE' gerado com sucesso com links para os arquivos em '$SRT_DIR'."
else
  echo "Nenhum arquivo .srt encontrado em '$SRT_DIR'."
  echo "Arquivo '$OUTPUT_FILE' criado apenas com o cabeçalho."
fi

exit 0