//
//  ViewController.swift
//  MusicList
//
//  Created by yas on 2020/03/26.
//  Copyright © 2020 yas. All rights reserved.
//

import Alamofire
import AlamofireImage
import MediaPlayer
import UIKit

struct MusicStruct {
    var name: String = ""
    var image: UIImage?
    var imageUrl: URL?
    var playlist: MPMediaItemCollection?
}

class ViewController: UIViewController {
    @IBOutlet weak private var collectionView: UICollectionView!
    private var musicPlaylists: [MusicStruct] = []
    private var player: MPMusicPlayerController?

    override func viewDidLoad() {
        super.viewDidLoad()

        player = MPMusicPlayerController.systemMusicPlayer

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MusicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MusicCollectionViewCell")

        // プレイリスト取得
        let myPlaylistQuery = MPMediaQuery.playlists()
        if let playlists = myPlaylistQuery.collections {
            for playlist in playlists.reversed() {
                var musicStruct = MusicStruct()

                // プレイリスト名取得
                if let name = playlist.value(forProperty: MPMediaPlaylistPropertyName) as? String {
                    musicStruct.name = name
                }

                // AppleMusicのアルバムアートワーク取得
                if let artworkCatalog = playlist.value(forKey: "artworkCatalog") as? NSObject,
                    let token = artworkCatalog.value(forKey: "token") as? NSObject,
                    let availableArtworkToken = token.value(forKey: "availableArtworkToken") as? String {

                    musicStruct.imageUrl = URL(string: availableArtworkToken)
                }

                // プレイリストのアルバムアートワーク取得
                if let image = playlist.representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80)) {
                    musicStruct.image = image
                }

                musicStruct.playlist = playlist
                musicPlaylists.append(musicStruct)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        musicPlaylists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicCollectionViewCell", for: indexPath) as? MusicCollectionViewCell else {
            fatalError("no identified cell.")
        }
        // タイトル設定
        cell.titleLabel.text = musicPlaylists[indexPath.row].name

        // AppleMusicのartworkを優先して設定
        if let imageUrl = musicPlaylists[indexPath.row].imageUrl {
            cell.imageView.af.setImage(withURL: imageUrl)
        } else {
            cell.imageView.image = musicPlaylists[indexPath.row].image ?? Image(systemName: "headphones")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 曲を再生
        if let playlist = musicPlaylists[indexPath.row].playlist {
            player?.setQueue(with: playlist)
            player?.play()
        }
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    }
}
