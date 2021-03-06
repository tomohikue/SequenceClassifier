####################################################################################################
#                                                                                                  #
#   Path定義
#                                                                                                  #
####################################################################################################

$testDataFilePath =       "..\Data\TestData.csv"
$word2IndexFilePath =     "..\Data\words.csv"
$cntkOutputDataFilePath = "..\Data\CNTKOutputData.txt.p"
$cntkTestResultFilePath = "..\Data\TestResult.tsv"
$cntkConfigFilePath =     "..\Config\Test.cntk"

####################################################################################################
#                                                                                                  #
#   メイン処理
#                                                                                                  #
####################################################################################################

$Error.Clear()

try
{
"Test Start"

    # 単語辞書データを取得    
    $word2IndexDictionary = @{}
    $word2IndexFileContents = Import-Csv  -Encoding UTF8 -Path $word2IndexFilePath -Delimiter "," -ErrorAction Stop
    foreach($item in $word2IndexFileContents)
    {
        $word2IndexDictionary.Add($item.Value, $item.Index)
    }

    # テスト用データを取得する。
    $testDataArray = @()
    $testDataFileContents = Import-Csv  -Encoding UTF8 -Path $testDataFilePath -Delimiter ","
    foreach($item in $testDataFileContents)
    {
        $testDataArray += @{SourceText=$item.SourceText; WakachigakiText=$item.wakachigakiText; LabelIndex=$item.LabelIndex; LabelIndexVector=$item.LabelIndexVector;}
    }

    # CNTKに予測を行わせる
    cntk.exe configFile=$cntkConfigFilePath
    if($LASTEXITCODE -eq 1){ 
        # イベントログに出力
        $errorMessage = "cntk.exeの実行中にエラーが発生しました。"
    }

    $cntkoutputList = @()
    $cntkoutputList = Get-Content -Encoding UTF8 -Path $cntkOutputDataFilePath -ErrorAction Stop

    $testResultList = @()

    #CNTKにはカラの入力はエラーとなるので入力データから省いている。そのため結果からもカラになる文章は省かれるため、カウンターで行の整合性をとる
    $cntkoutputListPopCount = 0

    for ($i=0; $i -lt $testDataArray.Count; $i++)
    {
            $CNTKSoftmaxArray = @()
            $CNTKSoftmaxArray = $cntkoutputList[$cntkoutputListPopCount].Split(" ")
            $cntkoutputListPopCount = $cntkoutputListPopCount + 1

            $max_prob_index = 0
            $max_prob = 0
            $max2_prob_index = 0
            $max2_prob = 0
            $max3_prob_index = 0
            $max3_prob = 0

            for ($j = 0; $j -lt $CNTKSoftmaxArray.Count; $j++){
                if([double]$CNTKSoftmaxArray[$j] -gt $max_prob){
                    $max3_prob_index = $max2_prob_index
                    $max3_prob = $max2_prob
                    $max2_prob_index = $max_prob_index
                    $max2_prob = $max_prob
                    $max_prob_index = $j
                    $max_prob = [double]$CNTKSoftmaxArray[$j]

                }elseif([double]$CNTKSoftmaxArray[$j] -gt $max2_prob){
                    $max3_prob_index = $max2_prob_index
                    $max3_prob = $max2_prob
                    $max2_prob_index = $j
                    $max2_prob = [double]$CNTKSoftmaxArray[$j]
                }elseif([double]$CNTKSoftmaxArray[$j] -gt $max3_prob){
                    $max3_prob_index = $j
                    $max3_prob = [double]$CNTKSoftmaxArray[$j]
                }
            }
            
            if ($max_prob_index -eq $testDataArray[$i].LabelIndex) {
                $correctCount = $correctCount +1
            }                


            # テスト結果を確認したい場合コメントアウト
            $testResultList += $testDataArray[$i].SourceText + "`t" + $testDataArray[$i].LabelIndex + "`t" + $testDataArray[$i]. LabelIndexVector + "`t" + $max_prob_index + "`t" + $max_prob+ "`t" + $max2_prob_index + "`t" + $max2_prob+ "`t" + $max3_prob_index + "`t" + $max3_prob
        # }
    }

    $resultList = @()
    $resultList += "TestText`tcorrect`tcorrect_Multi`tpredict_1`tconficence_1`tpredict_2`tconficence_2`tpredict_3`tconficence_3"
    $resultList += $testResultList

    # テスト結果を確認したい場合コメントアウト
    Set-Content $cntkTestResultFilePath -Encoding UTF8 -Force -Value $resultList

    }
catch
{
    # 例外情報の抽出
    $errorMessage = "例外が発生しました。" + $Error[0]
    # 標準エラー出力に出力
    Write-Error $errorMessage

    exit 1
}

"Test End"
# 終了コード（正常終了）
exit 0
