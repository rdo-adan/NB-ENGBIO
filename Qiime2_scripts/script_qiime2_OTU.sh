#!/bin/bash

echo -e "\033[0;34mTenha certeza que o qiime2-amplicon está instalado em um ambiente separado para não haver conflito com outros pacotes."
echo -e "\033[0;34mScript feito para a versão qiime2 2024.5 Amplicon Distribution."
echo -e "\033[0;34mScript escrito para 16s total com base de dados GreenGenes 2024.09 e classificador treinado, veja o Read.me para obter detalhes e links para download das versões aqui utilizadas."
echo -e "\033[0;34mScript originalmente montado para SingleEndFastq, com uso de manifesto."
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

# 3. Desduplicar sequências e gerar tabela de frequências e sequências representativas
echo -e "\033[0;35mDesduplicando sequências e gerando tabela de frequências."
qiime vsearch dereplicate-sequences \
  --i-sequences "$DEMUX_OUTPUT" \
  --o-dereplicated-table "${OUTPUT_DIR}/table.qza" \
  --o-dereplicated-sequences "${OUTPUT_DIR}/rep-seqs.qza"
echo -e "\033[0;32mDesduplicação concluída."

# 4. Clusterizar em OTUs com 97% de similaridade usando VSEARCH
echo -e "\033[0;35mAgrupando sequências em OTUs com 97% de similaridade."
qiime vsearch cluster-features-de-novo \
  --i-sequences "${OUTPUT_DIR}/rep-seqs.qza" \
  --i-table "${OUTPUT_DIR}/table.qza" \
  --p-perc-identity 0.97 \
  --p-threads 12 \
  --o-clustered-table "${OUTPUT_DIR}/otu-table.qza" \
  --o-clustered-sequences "${OUTPUT_DIR}/otu-rep-seqs.qza"
echo -e "\033[0;32mAgrupamento de OTUs concluído."

# 5. Visualizar OTUs e estatísticas
echo -e "\033[0;35mgerando arquivos de visualização de OTUs."
qiime feature-table summarize \
  --i-table "${OUTPUT_DIR}/otu-table.qza" \
  --o-visualization "${OUTPUT_DIR}/otu-table.qzv"

qiime feature-table tabulate-seqs \
  --i-data "${OUTPUT_DIR}/otu-rep-seqs.qza" \
  --o-visualization "${OUTPUT_DIR}/otu-rep-seqs.qzv"
echo -e "\033[0;32mConcluído, veja ${OUTPUT_DIR} para OTUs."


# 6. Atribuir taxonomia para OTUs
echo -e "\033[0;35matribuindo taxonomia."
qiime feature-classifier classify-sklearn \
  --i-classifier "$CLASSIFIER_PATH" \
  --i-reads "${OUTPUT_DIR}/otu-rep-seqs.qza" \
  --o-classification "${OUTPUT_DIR}/taxonomy.qza"
echo -e "\033[0;32matribuição de taxonomia concluída."

# 7. Visualizar resultados da taxonomia para OTUs
echo -e "\033[0;35mgerando arquivos de visualização."
qiime metadata tabulate \
  --m-input-file "${OUTPUT_DIR}/taxonomy.qza" \
  --o-visualization "${OUTPUT_DIR}/taxonomy.qzv"
echo -e "\033[0;32mConcluído, veja ${OUTPUT_DIR} para resultados de taxonomia."

# 8. Gerar árvore filogenética a partir de OTUs
echo -e "\033[0;35mGerando árvore filogenética."
qiime alignment mafft \
  --i-sequences "${OUTPUT_DIR}/otu-rep-seqs.qza" \
  --o-alignment "${OUTPUT_DIR}/aligned-otu-rep-seqs.qza"
  echo -e "\033[0;32m1/4"

qiime alignment mask \
  --i-alignment "${OUTPUT_DIR}/aligned-otu-rep-seqs.qza" \
  --o-masked-alignment "${OUTPUT_DIR}/masked-aligned-otu-rep-seqs.qza"
echo -e "\033[0;32m2/4"

qiime phylogeny fasttree \
  --i-alignment "${OUTPUT_DIR}/masked-aligned-otu-rep-seqs.qza" \
  --o-tree "${OUTPUT_DIR}/unrooted-tree.qza"
echo -e "\033[0;32m3/4"

qiime phylogeny midpoint-root \
  --i-tree "${OUTPUT_DIR}/unrooted-tree.qza" \
  --o-rooted-tree "${OUTPUT_DIR}/rooted-tree.qza"
echo -e "\033[0;32m4/4 Árvore filogenética gerada."

# 9. Exportar a árvore filogenética no formato .nwk
echo -e "\033[0;35mExportando a árvore filogenética para o formato .nwk."
qiime tools export \
  --input-path "${OUTPUT_DIR}/rooted-tree.qza" \
  --output-path "${OUTPUT_DIR}/tree-output"
echo -e "\033[0;32mExportação concluída para ${OUTPUT_DIR}/tree-output."

# Fim do script
echo -e "\033[0;32mScript finalizado, verifique todos os arquivos gerados em: ${OUTPUT_DIR}."
echo -e "\033[0;33mObrigado por usar este script, veja outros em nosso repositório no GitHub > NB-ENGBIO <"
