
//LAB example

// const dataSet = [
//   [['A'],['B'],['F','G'], ['C'], ['D']],
//   [['B'], ['G'], ['D']],
//   [['B'], ['F'], ['G'], ['A','B']],
//   [['F'], ['A','B'], ['C'], ['D']],
//   [['A'], ['B','C'], ['G'], ['F'], ['D','E']]
// ];

//Lecture example
const dataSet = [
  [
    ['b', 'd'],
    ['c'],
    ['b']
  ],
  [
    ['b', 'f'],
    ['c', 'e'],
    ['b']
  ],
  [
    ['a', 'g'],
    ['b']
  ],
  [
    ['b', 'e'],
    ['c', 'e']
  ],
  [
    ['a'],
    ['b', 'd'],
    ['b'],
    ['c'],
    ['b']
  ]
];

const minSupport = 0.3;
int minSupportCount = (minSupport * dataSet.length).ceil();

void main() {
  List<String> freqOneItems = InitialSets.getFreq1Items();
  
  print("___________________");

  List<List<List<String>>> freqNItemSets = NItemSets.getNFreqItemsets(freqOneItems, 2);
  
  
  int n = 3;
  while(freqNItemSets.length > 1){
    print("___________________");
    freqNItemSets = NItemSets.getNFreqItemsets(freqNItemSets, n);
    n++;
  }

}


abstract class InitialSets {
  static Map<String, int> _initializeCandidatesMap() {
    Map<String, int> candidatesMap = {};

    for (var i = 0; i < dataSet.length; i++) {
      for (var j = 0; j < dataSet[i].length; j++) {
        for (var k = 0; k < dataSet[i][j].length; k++) {
          candidatesMap[dataSet[i][j][k]] = 0;
        }
      }
    }
    candidatesMap = Map.fromEntries(candidatesMap.entries.toList()
      ..sort((e1, e2) => e1.key.compareTo(e2.key))); // sort map keys
    return candidatesMap;
  }

  static Map<String, int> _generateCandidatesOfSizeOne() {
    var candidatesMap = _initializeCandidatesMap();

    for (var i = 0; i < dataSet.length; i++) {
      List transaction = [];
      for (var j = 0; j < dataSet[i].length; j++) {
        transaction = [...transaction, ...dataSet[i][j]];
      }
      transaction = transaction.toSet().toList();

      for (var k = 0; k < transaction.length; k++)
        candidatesMap[transaction[k]] = candidatesMap[transaction[k]]! + 1;
    }

    return candidatesMap;
  }

  static List<String> getFreq1Items() {
    Map<String, int> size1Candidates = _generateCandidatesOfSizeOne();
    List<String> freq1Items = [];
    Map<String, int> size1Frequency = _generateCandidatesOfSizeOne();
    size1Frequency.removeWhere((key, value) => value < minSupportCount);
    print("Frequent 1 ItemSet : ");
    
    size1Candidates.removeWhere((item, support) => support < minSupportCount);
    
    size1Candidates.forEach((item, support) {
      print("$item : $support");
    });

    return size1Candidates.keys.toList();
  }
}

abstract class Size2ItemSets {
  static List<List<List<String>>> _generateCandidatesOfSizeTwo(List<String> freq1Itemsets) {
    List<List<List<String>>> two_ItemSets = [];

    for (int i = 0; i < freq1Itemsets.length; i++) {
      String firstItem = freq1Itemsets[i];

      two_ItemSets.add([
        [firstItem],
        [firstItem]
      ]);

      for (int j = i + 1; j < freq1Itemsets.length; j++) {
        String secondItem = freq1Itemsets[j];
        two_ItemSets.add([
          [firstItem, secondItem]
        ]);
        two_ItemSets.add([
          [firstItem],
          [secondItem]
        ]);
        two_ItemSets.add([
          [secondItem],
          [firstItem]
        ]);
      }
    }
    return two_ItemSets;
  }
}





// where N > 2
abstract class NItemSets {
  
  
  
  static List<List<List<String>>> getNFreqItemsets(var freqItemsets, int n) {
    
    List<List<List<String>>> candidates;
    
    if(n == 2){
      candidates = Size2ItemSets._generateCandidatesOfSizeTwo(freqItemsets);
    }
    else {
      candidates = _generateCandidatesSizeN(n, freqItemsets);
      candidates = removeDuplicateCandidates(candidates);
      pruneCandidates(candidates, freqItemsets);
    }
    
    
    Map<List<List<String>>, int> freq2ItemSet = {};
    
    for(List<List<String>> candidate in candidates){
      
      int support = 0;
      for(var transaction in dataSet){
        if(isSubsequent(transaction, candidate)){
          support++;
        }
      }
      freq2ItemSet[candidate] = support;
      
    }
    
    
    
    freq2ItemSet.removeWhere((key, support) => support < minSupportCount);
    
    print("Frequent $n ItemSet : ");
    freq2ItemSet.forEach((k, v) => print("${k} : ${v}"));
    
    return freq2ItemSet.keys.toList();
  }

  static bool isSubsequent(List<List<String>> transaction, List<List<String>> candidate) {
    
    List<List<int>> occurances = [];
 
    for(int i = 0; i < candidate.length; i++){
      var element = candidate[i];
      occurances.add([]);
      
      for(int j = 0; j < transaction.length; j++){
        var seq = transaction[j];
        if(isSublist(seq, element)){
          occurances[i].add(j);
        }
      }
      
    }
    
    int lastElementIndex = -1;
    bool found = false;
    
    for(int i = 0; i < candidate.length; i++){
      var element = candidate[i];
      
      found = false;
      for(int j = 0; j < occurances[i].length; j++){
        if(occurances[i][j] > lastElementIndex){
          lastElementIndex = occurances[i][j];
          found = true;
          break;
        }
      }
      
      if(!found){
        return false;
      }
      
      
    }
    
    return true;
    
  }
  
  static bool isSublist(List<String> big, List<String> small) {
    final setA = Set.of(big);
    return setA.containsAll(small);
  }
  
  
  static _generateCandidatesSizeN( int n, List<List<List<String>>> freqNMinus1Itemset) {
    final freqIS = freqNMinus1Itemset;

    List<List<List<String>>> candidates = [];

    for (int i = 0; i < freqIS.length; i++) {
      final seq1 = freqIS[i];
      List<List<List<String>>> seq1Possibilities = removeItemFromSeq(seq1, removeIndex: 0);

      for (int j = 0; j < freqIS.length; j++) {
        final seq2 = freqIS[j];
        if (seq1 == seq2) {
          continue;
        }

        List<List<List<String>>> seq2Possibilities =
            removeItemFromSeq(seq2, removeIndex: seq2.length - 1);

        bool canJoin = canJoinSequences(seq1Possibilities, seq2Possibilities);

        if (canJoin) {
          var joined = join2Seq(seq1, seq2, n);
          candidates.add(joined);
        }
      }
    }
    
    return candidates;
  }

  static List<List<String>> join2Seq(List<List<String>> seq1, List<List<String>> seq2, int size) {
    List<List<String>> joined = [];

    final seq1FirstItem = seq1.first;
    final seq2LastItem = seq2.last;

    if (seq1FirstItem.length + seq2LastItem.length == size) {
      joined = [seq1FirstItem, seq2LastItem];
    } else if (seq1FirstItem.length + seq2LastItem.length < size) {
      var middle;
      if (seq1.length < seq2.length) {
        final copySeq1 = deepCopy(seq1);
        copySeq1.removeAt(0);
        middle = copySeq1;
      } else {
        final copySeq2 = deepCopy(seq2);
        copySeq2.removeLast();
        middle = copySeq2;
      }

      joined = [seq1FirstItem, ...middle, seq2LastItem];
    } else {
      // > size
      //merge
      var merged = (seq1FirstItem + seq2LastItem).toSet().toList();
      joined = [merged];
    }

    return joined;
  }

  
  static List<List<List<String>>> removeItemFromSeq(List<List<String>> freqNMinus1Itemset,{required int removeIndex}) {
    int itemIndex = removeIndex;

    List<List<List<String>>> allPossibilities = [];

    List<String> removedItem = freqNMinus1Itemset[itemIndex];

    if (removedItem.length == 1) {
      List<List<String>> copyFreqItemSet = deepCopy(freqNMinus1Itemset);
      copyFreqItemSet.removeAt(itemIndex);
      allPossibilities = [copyFreqItemSet];
    } else {
      for (int i = 0; i < removedItem.length; i++) {
        String event = removedItem[i];
        var copyFreqItemSet = deepCopy(freqNMinus1Itemset);
        copyFreqItemSet[itemIndex] = [event];
        allPossibilities.add(copyFreqItemSet);
      }
    }

    return allPossibilities;
  }

  
  static bool canJoinSequences(List<List<List<String>>> seq1Possibilities, List<List<List<String>>> seq2Possibilities) {

    for (List<List<String>> seq1 in seq1Possibilities) {
      for (List<List<String>> seq2 in seq2Possibilities) {
        if (seq1.length == seq2.length) {
          for (int i = 0; i < seq1.length; i++) {
            List<String> item1 = seq1[i];
            List<String> item2 = seq2[i];

            if (item1.length != item2.length) {
              break;
              //take next seq, this cannot be joined
            } else {
              bool areStringsMatching = true;
              for (int j = 0; j < item1.length; j++) {
                if (item1[j] != item2[j]) {
                  areStringsMatching = false;
                  break;
                }
              }

              if (!areStringsMatching) {
                break;
              } else if (i == seq1.length - 1) {
                return true;
              }
            }
          }
        }
      }
    }

    return false;
  }

  
  static List<List<String>> deepCopy(List<List<String>> source) {
    return source.map((e) => e.toList()).toList();
  }

  
  static List<List<List<String>>> removeDuplicateCandidates(List<List<List<String>>> candidates) {
    List<List<List<String>>> candidatesAfter = [];
    
    for (List<List<String>> seq1 in candidates) {
      
      bool hasDuplicate = false;
      
      for (List<List<String>> seq2 in candidatesAfter) {

        
        if (seq1.length == seq2.length) {
          
          bool areStringsMatching = true;
          
          for (int i = 0; i < seq1.length; i++) {
            List<String> item1 = seq1[i];
            List<String> item2 = seq2[i];

            if (item1.length != item2.length) {
              areStringsMatching = false;
              break;
            }
            
            else {
              
              for (int j = 0; j < item1.length; j++) {
                if (item1[j] != item2[j]) {
                  areStringsMatching = false;
                  break;
                }
              }

              if (!areStringsMatching) {
                break;
              }
              
            }
          }
          
          if(areStringsMatching){
            hasDuplicate = true;
          }
          
        }
        
      }
      
      
      if (!hasDuplicate) {
         candidatesAfter.add(seq1);
      }
      
    }
    
    return candidatesAfter;
    
  }
  
  
  static void pruneCandidates(List<List<List<String>>> candidates, List<List<List<String>>> freqNMinus1) {
    List<List<List<String>>> candidatesAfter = [];
    
    for (List<List<String>> candidate in candidates) {
      
      bool allPosExist = true;
      
      for(int i = 0; i < candidate.length; i++){

        List<List<List<String>>> posibilities = removeItemFromSeq(candidate, removeIndex : i);
                
        for(var posibility in posibilities){
          
          bool posExistInDataset = false;
          
          for(var freqItemset in freqNMinus1){
            if(isSubsequent(posibility, freqItemset)){
              posExistInDataset = true;
              break;
            }
          }
          
          if(!posExistInDataset){
            allPosExist = false;
            break;
          }
          
        }
        
        if(!allPosExist){
          break;
        }
        
        
      }
      
      if(allPosExist){
        candidatesAfter.add(candidate);
      }
      
      
      
    }
    
    candidates = candidatesAfter;
    
  }
  
}

