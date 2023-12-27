import os
import networkx as nx # https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.connectivity.cuts.minimum_edge_cut.html#networkx.algorithms.connectivity.cuts.minimum_edge_cut

Connections = []

# with open(os.path.join(os.path.dirname(__file__), 'DataDemo.txt'), 'r') as Data:
with open(os.path.join(os.path.dirname(__file__), 'Data.txt'), 'r') as Data:
	for DataLine in Data:
		Component1, OtherComponents = DataLine.split(":")
		for Component in OtherComponents.strip().split(' '):
			Connections.append([Component1.strip(), Component.strip()])
NXGraph = nx.Graph(Connections)
EdgesToRemove = nx.minimum_edge_cut(NXGraph)
NXGraph.remove_edges_from(EdgesToRemove)
Split1, Split2 = nx.connected_components(NXGraph)
Result = len(Split1) * len(Split2)

print(Result)
# Correct answer = 600225 (54 for testdata)