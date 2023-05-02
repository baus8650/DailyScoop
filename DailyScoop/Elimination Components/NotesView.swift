//
//  NotesView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/2/23.
//

import SwiftUI

struct NotesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var notes: String?
    
    var body: some View {
        VStack {
            Text("**Notes**")
                .padding(.top, 12)
                .foregroundColor(Color("mainColor"))
            ScrollView {
                if let notes {
                    Text(notes)
                        .foregroundColor(Color("mainColor"))
                        .lineLimit(nil)
                        .padding(4)
                        .padding([.leading, .trailing], 4)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Couldn't load notes.")
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: UIColor.systemBackground))
            )
            .padding(.horizontal, 8)
            Button {
                notes = nil
                dismiss()
            } label: {
                Text("**Close**")
                    .foregroundColor(Color("mainColor"))
            }
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("buttonBackground"))
        )
//        .frame(width: 270)
//        .frame(maxHeight: 212)
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView(notes: .constant("Here is some sample text aspodihapoiwuhvpaoiusdhfaojsndvnpo po haposid poin asdoi aposidp oipoij asdon asdon asdpoviu paosid p po iaspdoi as vas dviuoah rgpiuhawer asd as dg ag hwuoerghp98asdpoihasv a gqngqreoighasdoiasg ga gqnoufenuaf apoia sdv av aniuoaegfphaiosdf Here is some sample text aspodihapoiwuhvpaoiusdhfaojsndvnpo po haposid poin asdoi aposidp oipoij asdon asdon asdpoviu paosid p po iaspdoi as vas dviuoah rgpiuhawer asd as dg ag hwuoerghp98asdpoihasv a gqngqreoighasdoiasg ga gqnoufenuaf apoia sdv av aniuoaegfphaiosdf Here is some sample text aspodihapoiwuhvpaoiusdhfaojsndvnpo po haposid poin asdoi aposidp oipoij asdon asdon asdpoviu paosid p po iaspdoi as vas dviuoah rgpiuhawer asd as dg ag hwuoerghp98asdpoihasv a gqngqreoighasdoiasg ga gqnoufenuaf apoia sdv av aniuoaegfphaiosdf Here is some sample text aspodihapoiwuhvpaoiusdhfaojsndvnpo po haposid poin asdoi aposidp oipoij asdon asdon asdpoviu paosid p po iaspdoi as vas dviuoah rgpiuhawer asd as dg ag hwuoerghp98asdpoihasv a gqngqreoighasdoiasg ga gqnoufenuaf apoia sdv av aniuoaegfphaiosdf Here is some sample text aspodihapoiwuhvpaoiusdhfaojsndvnpo po haposid poin asdoi aposidp oipoij asdon asdon asdpoviu paosid p po iaspdoi as vas dviuoah rgpiuhawer asd as dg ag hwuoerghp98asdpoihasv a gqngqreoighasdoiasg ga gqnoufenuaf apoia sdv av aniuoaegfphaiosdf "))
    }
}
