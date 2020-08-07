/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

use servo_atoms::Atom;
use std::fmt;
use std::fs::File;
use std::io::{Error, Read};
use std::path::PathBuf;
use std::sync::RwLock;
use webrender_api::NativeFontHandle;

/// Platform specific font representation for Linux.
/// The identifier is an absolute path, and the bytes
/// field is the loaded data that can be passed to
/// freetype and Raqote directly.
#[derive(Deserialize, Serialize)]
pub struct FontTemplateData {
    // If you add members here, review the Debug impl below
    pub bytes: RwLock<Option<Arc<Vec<u8>>>>,
    pub identifier: Atom,
}

impl fmt::Debug for FontTemplateData {
    fn fmt(&self, fmt: &mut fmt::Formatter) -> fmt::Result {
        fmt.debug_struct("FontTemplateData")
            .field(
                "bytes",
                &self
                    .bytes
                    .read()
                    .unwrap()
                    .as_ref()
                    .map(|b| format!("[{} bytes]", b.len())),
            )
            .field("identifier", &self.identifier)
            .finish()
    }
}

impl FontTemplateData {
    pub fn new(identifier: Atom, bytes: Option<Vec<u8>>) -> Result<FontTemplateData, Error> {
        Ok(FontTemplateData {
            bytes: RwLock::new(bytes.map(Arc::new)),
            identifier: identifier,
        })
    }

    /// Returns a clone of the data in this font. This may be a hugely expensive
    /// operation (depending on the platform) which performs synchronous disk I/O
    /// and should never be done lightly.
    pub fn bytes(&self) -> Arc<Vec<u8>> {
        let bytes = self.bytes.write().unwrap();
        if let Some(bytes) = bytes.deref() {
            return bytes.clone();
        }
        let mut file = File::open(&*self.identifier).expect("Couldn't open font file!");
        let mut buffer = vec![];
        file.read_to_end(&mut buffer).unwrap();
        let buffer = Arc::new(buffer);
        *bytes = Some(buffer.clone());
        buffer
    }

    /// Returns a clone of the bytes in this font if they are in memory. This function never
    /// performs disk I/O.
    pub fn bytes_if_in_memory(&self) -> Option<Arc<Vec<u8>>> {
        self.bytes.read().unwrap().deref().clone()
    }

    /// Returns the native font that underlies this font template, if applicable.
    pub fn native_font(&self) -> Option<NativeFontHandle> {
        if self.bytes.is_none() {
            Some(NativeFontHandle {
                path: PathBuf::from(&*self.identifier),
                index: 0,
            })
        } else {
            None
        }
    }
}
