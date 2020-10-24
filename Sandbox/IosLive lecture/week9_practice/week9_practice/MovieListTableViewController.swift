//
//  MovieListTableViewController.swift
//  week9_practice
//
//  Created by Ted Kim on 2020/10/04.
//

import UIKit



class MovieListTableViewController: UITableViewController {
    
    struct Movie {
        
        let title: String
        let director: String
        let actor: String
        
    }

    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)

        let movies0 = Movie(title: "인셉션", director: "크리스토퍼놀란", actor: "디카프리오")
        let movies1 = Movie(title: "테넷", director: "크리스토퍼놀란", actor: "존데이비드워싱턴")
        let movies2 =  Movie(title: "인터스텔라", director: "크리스토퍼놀란", actor: "디카프리오")
        let movies3 =  Movie(title: "반도", director: "연상호", actor: "강동원")
        let movies4 =  Movie(title: "살아있다", director: "크리스토퍼놀란", actor: "유아인")
        movies.append(movies0)
        movies.append(movies1)
        movies.append(movies2)
        movies.append(movies3)
        movies.append(movies4)
        
        cell.textLabel?.text = "\(movies[indexPath.row].title)"

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let index = tableView.indexPath(for: cell){
            let selected = movies[index.row]
            }
        }
    }
}
