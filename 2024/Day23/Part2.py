import os
import networkx as nx # https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.connectivity.cuts.minimum_edge_cut.html#networkx.algorithms.connectivity.cuts.minimum_edge_cut

Connections = []

# with open(os.path.join(os.path.dirname(__file__), 'DataDemo.txt'), 'r') as Data:
with open(os.path.join(os.path.dirname(__file__), 'Data.txt'), 'r') as Data:
	for DataLine in Data:
		Connections.append(DataLine.strip().split('-'))
NXGraph = nx.Graph(Connections)
LargestSet = max(list(nx.find_cliques(NXGraph)), key=len)

print (','.join(sorted(LargestSet)))
# Correct answer = af,aq,ck,ee,fb,it,kg,of,ol,rt,sc,vk,zh (co,de,ka,ta for testdata)