#!/bin/bash

echo -e "\033[0;34mTenha certeza que o qiime2-amplicon está instalado em um ambiente separado para não haver conflito com outros pacotes."
echo
echo -e "\033[0;34mScript feito para a versão qiime2 2024.5 Amplicon Distribution."
echo
echo -e "\033[0;34mScript escrito para 16s total com base de dados GreenGenes 2024.09 e classificador treinado, veja o Read.me para obter detalhes e links para download das versões aqui utilizadas."
echo
echo -e "\033[0;34mScript originalmente montado para SingleEndFastq, com uso de manifesto."
echo
echo -e "\033[0;34mAltere-o para atender as suas necessidades ou entre em contado via GitHub."
echo
echo
echo
echo -e "\033[0;32miniciando script..."

# Verificar se o número correto de parâmetros foi passado
if [ "$#" -ne 3 ]; then
  echo -e "\033[0;31mUso: $0 <caminho_para_manifest.tsv> <caminho_para_classificador.qza> <output_directory>"
  exit 1
fi

# Atribuir argumentos a variáveis
MANIFEST_PATH="$1"
CLASSIFIER_PATH="$2"
OUTPUT_DIR="$3"
DEMUX_OUTPUT="${OUTPUT_DIR}/demux.qza"

# Criar o diretório de saída se ele não existir
echo -e "\033[0;35mcriando diretório de saída"
mkdir -p "$OUTPUT_DIR"
echo -e "\033[0;32mDiretório criado com sucesso."

# 1. Importar dados
echo -e "\033[0;35mimportando dados."
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path "$MANIFEST_PATH" \
  --output-path "$DEMUX_OUTPUT" \
  --input-format SingleEndFastqManifestPhred33V2
echo -e "\033[0;32mimportação de dados concluída."

# 2. Visualizar dados importados
echo -e "\033[0;35mcriando visualização dos dados importados."
qiime demux summarize \
  --i-data "$DEMUX_OUTPUT" \
  --o-visualization "${OUTPUT_DIR}/demux-summary.qzv"
echo -e "\033[0;32mconcluído, verifique ${OUTPUT_DIR}."

# 3. Truncar leituras com base na qualidade
echo -e "\033[0;33mse quiser definir outro valor mínimo de qualidade veja o arquivo demux-summary.qzv gerado.\033[0;33m"
echo -e "\033[0;35mtruncando leituras com base na qualidade."
qiime dada2 denoise-single \
  --i-demultiplexed-seqs "$DEMUX_OUTPUT" \
  --p-trim-left 0 \
  --p-trunc-len 0 \
  --p-max-ee 3 \
  --p-trunc-q 10 \
  --o-representative-sequences "${OUTPUT_DIR}/rep-seqs.qza" \
  --o-table "${OUTPUT_DIR}/table.qza" \
  --o-denoising-stats "${OUTPUT_DIR}/denoising-stats.qza"
echo -e "\033[0;32mtruncamento concluído."

# 4. Desduplicar e identificar ASVs
echo -e "\033[0;35midentificando ASVs."
qiime dada2 denoise-single \
  --i-demultiplexed-seqs "$DEMUX_OUTPUT" \
  --p-trim-left 0 \
  --p-trunc-len 0 \
  --o-representative-sequences "${OUTPUT_DIR}/rep-seqs.qza" \
  --o-table "${OUTPUT_DIR}/table.qza" \
  --o-denoising-stats "${OUTPUT_DIR}/denoising-stats.qza"
echo -e "\033[0;32midentificação de ASVs concluída."

# 5. Visualizar ASVs e estatísticas
echo -e "\033[0;35mgerando arquivos de visualização."
qiime feature-table summarize \
  --i-table "${OUTPUT_DIR}/table.qza" \
  --o-visualization "${OUTPUT_DIR}/table.qzv"

qiime feature-table tabulate-seqs \
  --i-data "${OUTPUT_DIR}/rep-seqs.qza" \
  --o-visualization "${OUTPUT_DIR}/rep-seqs.qzv"
echo -e "\033[0;32mconcluido, veja ${OUTPUT_DIR}."

# 6. Atribuir taxonomia
echo -e "\033[0;35matribuindo taxonomia."
qiime feature-classifier classify-sklearn \
  --i-classifier "$CLASSIFIER_PATH" \
  --i-reads "${OUTPUT_DIR}/rep-seqs.qza" \
  --o-classification "${OUTPUT_DIR}/taxonomy.qza"
echo -e "\033[0;32matribuição concluída."

# 7. Visualizar resultados da taxonomia
echo -e "\033[0;35mgerando arquivos de visualização."
qiime metadata tabulate \
  --m-input-file "${OUTPUT_DIR}/taxonomy.qza" \
  --o-visualization "${OUTPUT_DIR}/taxonomy.qzv"
echo -e "\033[0;32mconcluido, veja ${OUTPUT_DIR}."

# 8. Gerar árvore filogenética
echo -e "\033[0;35mgerando árvore filogenética."
qiime alignment mafft \
  --i-sequences "${OUTPUT_DIR}/rep-seqs.qza" \
  --o-alignment "${OUTPUT_DIR}/aligned-rep-seqs.qza"
echo -e "\033[0;32m1/4"
qiime alignment mask \
  --i-alignment "${OUTPUT_DIR}/aligned-rep-seqs.qza" \
  --o-masked-alignment "${OUTPUT_DIR}/masked-aligned-rep-seqs.qza"
echo -e "\033[0;32m2/4"
qiime phylogeny fasttree \
  --i-alignment "${OUTPUT_DIR}/masked-aligned-rep-seqs.qza" \
  --o-tree "${OUTPUT_DIR}/unrooted-tree.qza"
echo -e "\033[0;32m3/4"
qiime phylogeny midpoint-root \
  --i-tree "${OUTPUT_DIR}/unrooted-tree.qza" \
  --o-rooted-tree "${OUTPUT_DIR}/rooted-tree.qza"
echo -e "\033[0;32m4/4"

# 9. Exportar árvore no formato .nwk
echo -e "\033[0;35mexportando para arquivo .nwk"
qiime tools export \
  --input-path "${OUTPUT_DIR}/rooted-tree.qza" \
  --output-path "${OUTPUT_DIR}/tree-output"
echo -e "\033[0;32mexportado para ${OUTPUT_DIR}."

# Fim do script
echo -e "\033[0;32mScript finalizado, verifique todos os arquivos gerados em: ${OUTPUT_DIR}."
echo -e "\033[0;33mObrigado por usar este script, veja outros em nosso repositório no GitHub > NB-ENGBIO <"
