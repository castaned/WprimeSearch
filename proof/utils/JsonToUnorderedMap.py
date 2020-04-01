import json

goldenFile = "Cert_271036-284044_13TeV_ReReco_07Aug2017_Collisions16_JSON.txt"

with open(goldenFile) as f:
  data = json.load(f)

print "    std::unordered_map<Int_t, std::vector<std::pair<Int_t,Int_t>>> GoldenJson;"
print "    std::vector<std::pair<Int_t,Int_t>> vv1;"


for run in data:
  for lumiBlock in data[run]:
    print  "    vv1.emplace_back(std::make_pair(%d,%d));" %(int(lumiBlock[0]),int(lumiBlock[1]))
  print "    GoldenJson[%d] = vv1;" %(int(run))
  print "    tvv1 = {};"
