//
//  ViewController.swift
//  MyProject007
//
//  Created by Георгий Евсеев on 20.06.22.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var petitionsFilter: String = ""
    var petitionsTitle = String()
    var petitionSearching: [Petition] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(openTapped))

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(startSearch))
        let urlString: String

        if navigationController?.tabBarItem.tag == 0 {
//             urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
//             urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
//                print(petitions)
                return
            }
        }
        performSelector(inBackground: #selector(submit), with: nil)
        showError()
    }

    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    @objc func openTapped() {
        let ac = UIAlertController(title: "We The People API of the Whitehouse", message: nil, preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            petitions = jsonPetitions.results
            petitionSearching = petitions
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @objc func startSearch() {
        let ac = UIAlertController(title: "Search...", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Open", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
        petitionSearching.removeAll()
    }

    @objc func submit(_ answer: String) {
        petitionsFilter.append(answer)
        for petition in petitions {
            if petition.title.contains(petitionsFilter) {
                petitionSearching.append(petition)}
                
                if petitionsFilter.isEmpty {
                    petitionSearching = petitions
                }
            }
            
            tableView.reloadData()
            petitionsFilter.removeAll()
        }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitionSearching.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitionSearching[indexPath.row]
        petitionsTitle = petition.title
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitionSearching[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
